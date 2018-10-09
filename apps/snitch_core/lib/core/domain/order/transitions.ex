defmodule Snitch.Domain.Order.Transitions do
  @moduledoc """
  Helpers for the `Order` state machine.

  The `Snitch.Domain.Order.DefaultMachine` makes direct use of these helpers.

  By documenting these handy functions, we encourage the developer of a custom
  state machine to use, extend or compose them to build large event transitions.
  """

  use Snitch.Domain

  alias BeepBop.Context
  alias Snitch.Data.Model.Package
  alias Snitch.Data.Schema.Order
  alias Snitch.Data.Model.Payment, as: PaymentModel

  alias Snitch.Domain.Package, as: PackageDomain
  alias Snitch.Domain.{Payment, Shipment, ShipmentEngine, Splitters.Weight}
  alias Snitch.Domain.Order, as: OrderDomain
  alias Snitch.Tools.OrderEmail

  @doc """
  Embeds the addresses and computes some totals of the `order`.

  The following fields are required under the `:state` key:
  * `:billing_address` The billing `Address` params
  * `:shipping_address` The shipping `Address` params

  The following fields are computed: `item_total`, `tax_total` and `total`.
  `total` = `item_total` + `tax_total`
  > The promo and adjustment totals are ignored for now.
  """
  @spec associate_address(Context.t()) :: Context.t()
  def associate_address(
        %Context{
          valid?: true,
          struct: order,
          multi: multi,
          state: %{
            billing_address: billing,
            shipping_address: shipping
          }
        } = context
      ) do
    changeset =
      Order.partial_update_changeset(order, %{
        billing_address: billing,
        shipping_address: shipping
      })

    struct(context, multi: Multi.update(multi, :order, changeset))
  end

  def associate_address(%Context{} = context), do: struct(context, valid?: false)

  @doc """
  Computes a shipment fulfilling the `order`.

  Returns a new `Context.t` struct with the `shipment` under the the [`:state`,
  `:shipment`] key-path.

  > The `:state` key of the `context` is not utilised here.

  ## Note

  If `shipment` is `[]`, we DO NOT mark the `context` "invalid".
  """
  @spec compute_shipments(Context.t()) :: Context.t()
  # TODO: This function does not gracefully handle errors, they are raised!
  def compute_shipments(%Context{valid?: true, struct: order, state: state} = context) do
    order =
      if is_nil(order.shipping_address) do
        %{order | shipping_address: state.shipping_address}
      else
        order
      end

    shipment =
      order
      |> Shipment.default_packages()
      |> ShipmentEngine.run(order)
      |> Weight.split()

    struct(context, state: %{shipment: shipment})
  end

  def compute_shipments(%Context{valid?: false} = context), do: context

  @doc """
  Persists the computed shipment to the DB.

  `Package`s and their `PackageItem`s are inserted together in a DB transaction.

  The `packages` are added to the `:state` under the `:packages` key.
  Thus the signature of `context.state.packages` is,
  ```
  context.state.packages :: {:ok, [Pacakge.t()]} | {:error, Ecto.Changeset.t()}
  ```
  """
  @spec persist_shipment(Context.t()) :: Context.t()
  def persist_shipment(%Context{valid?: true, struct: %Order{} = order} = context) do
    %{state: %{shipment: shipment}} = context

    packages =
      Repo.transaction(fn ->
        shipment
        |> Stream.map(&Shipment.to_package(&1, order))
        |> Stream.map(&Package.create/1)
        |> fail_fast_reduce()
        |> case do
          {:error, error} ->
            Repo.rollback(error)

          {:ok, packages} ->
            packages
        end
      end)

    state = Map.put(context.state, :packages, packages)
    struct(context, state: state)
  end

  def persist_shipment(%Context{valid?: false} = context), do: context

  @doc """
  Removes the shipment belonging to Order from DB.

  Shipments which are basically `Package`s and their `PackageItem`s are
  removed together in a transaction.

  ```
  context.state.packages :: {:ok, [Pacakge.t()]} | {:error, Ecto.Changeset.t()}
  ```
  """
  def remove_shipment(%Context{valid?: true, struct: %Order{} = order} = context) do
    packages =
      Repo.transaction(fn ->
        order.packages
        |> Stream.map(&Package.delete/1)
        |> fail_fast_reduce()
        |> case do
          {:error, error} ->
            Repo.rollback(error)

          {:ok, packages} ->
            packages
        end
      end)

    case packages do
      {:ok, packages} ->
        state = Map.put(context.state, :packages, packages)
        struct(context, state: state)

      {:error, changeset} ->
        struct(context, valid?: false, errors: changeset)
    end
  end

  def remove_shipment(%Context{valid?: false} = context), do: context

  @doc """
  Persists the shipping preferences of the user in each `package` of the `order`.

  Along with the chosen `ShippingMethod`, we update package price fields. User's
  selection is assumed to be under the `context.state.shipping_preferences` key-path.

  ## Schema of the `:state`
  ```
  %{
    shipping_preferences: [
      %{
        package_id: string,
        shipping_method_id: non_neg_integer
      }
    ]
  }
  ```

  ## Assumptions
  * For each `package` of the `order`, a valid `shipping_method` must be chosen.
    > If an `order` has 3 packages, then
      `length(context.state.shipping_preferences)` must be `3`.
  * The chosen `shipping_method` for the `package` must be one among the
    `package.shipping_methods`.
  """
  @spec persist_shipping_preferences(Context.t()) :: Context.t()
  def persist_shipping_preferences(%Context{valid?: true, struct: %Order{} = order} = context) do
    %{state: %{shipping_preferences: shipping_preferences}, multi: multi} = context

    packages = Map.fetch!(Repo.preload(order, [:packages]), :packages)

    if validate_shipping_preferences(packages, shipping_preferences) do
      function = fn _ ->
        shipping_preferences
        |> Stream.map(fn %{package_id: package_id, shipping_method_id: shipping_method_id} ->
          packages
          |> Enum.find(fn %{id: id} -> id == package_id end)
          |> PackageDomain.set_shipping_method(shipping_method_id)
        end)
        |> fail_fast_reduce()
      end

      struct(context, multi: Multi.run(multi, :packages, function))
    else
      struct(context, valid?: false, errors: [shipping_preferences: "is invalid"])
    end
  end

  @doc """
  Marks all the `shipment` aka `packages` of an ordertransition from `pending`
  to the `processing` state.

  This function is a side effect of the transition in which payment for an
  order is made. In case of full payment of the order, all the packages should
  move to the processing stage.
  """
  @spec process_shipments(Context.t()) :: Context.t()
  def process_shipments(%Context{valid?: true, struct: %Order{} = order} = context) do
    params = [state: "processing"]
    package_update_multi = PackageDomain.update_all_for_order(Multi.new(), order, params)
    struct(context, multi: package_update_multi)
  end

  def process_shipments(%Context{valid?: false} = context), do: context

  @doc """
  Checks if `order` is fully paid for.

  The order total cost should match sum of all the `payments` for that `order`
  in `paid` state.
  """
  @spec confirm_order_payment_status(Context.t()) :: Context.t()
  def confirm_order_payment_status(%Context{valid?: true, struct: %Order{} = order} = context) do
    order_cost = OrderDomain.total_amount(order)
    order_payments_total = OrderDomain.payments_total(order, "paid")

    if order_cost == order_payments_total do
      context
    else
      struct(context, valid?: false, errors: [error: "balance due for order"])
    end
  end

  def confirm_order_payment_status(%Context{valid?: false} = context), do: context

  @doc """
  Tranistion function to handle payment creation.

  For more information see.
  ## See
  `Snitch.Domain.Payment`
  """
  @spec make_payment_record(Context.t()) :: Contex.t()
  def make_payment_record(
        %Context{
          valid?: true,
          struct: %Order{} = order,
          state: %{
            payment_method: payment_method,
            payment_params: payment_params
          }
        } = context
      ) do
    case Payment.create_payment(payment_params, payment_method, order) do
      {:ok, map} ->
        state = Map.put(context.state, :payment, map)
        struct(context, state: state)

      {:error, changeset} ->
        struct(context, valid?: false, errors: changeset.errors)
    end
  end

  @doc """
  Removes `payment` as well as corresponding `subpayment` type records created
  for an order in a transaction.
  """
  def remove_payment_record(%Context{valid?: true, struct: %Order{} = order} = context) do
    payments =
      Repo.transaction(fn ->
        order.payments
        |> Stream.map(&PaymentModel.delete/1)
        |> fail_fast_reduce()
        |> case do
          {:error, error} ->
            Repo.rollback(error)

          {:ok, payments} ->
            payments
        end
      end)

    case payments do
      {:ok, payments} ->
        state = Map.put(context.state, :payments, payments)
        struct(context, state: state)

      {:error, changeset} ->
        struct(context, valid?: false, errors: changeset)
    end
  end

  def remove_payment_record(%Context{valid?: false} = context), do: context

  def send_email_confirmation(
        %Context{valid?: true, struct: %Order{} = order, multi: multi} = context
      ) do
    multi =
      Multi.run(multi, :add_email, fn _ ->
        mail = OrderEmail.order_confirmation_mail(order)
        {:ok, mail}
      end)

    struct(context, state: context.state, multi: multi)
  end

  def send_email_confirmation(context), do: context

  def check_order_completion(
        %Context{valid?: true, struct: %Order{} = order, multi: multi} = context
      ) do
    context
    |> order_paid()
    |> packages_delivered()
  end

  def check_order_completion(context), do: context

  defp order_paid(%Context{valid?: true, struct: %Order{} = order, multi: multi} = context) do
    if OrderDomain.payments_total(order, "paid") == OrderDomain.total_amount(order) do
      context
    else
      struct(context, valid?: false, errors: [error: "Payment due for order"])
    end
  end

  defp order_paid(context), do: context

  defp packages_delivered(
         %Context{valid?: true, struct: %Order{} = order, multi: multi} = context
       ) do
    if OrderDomain.order_package_delivered?(order) do
      context
    else
      struct(context, valid?: false, errors: [error: "Packages not delivered"])
    end
  end

  defp packages_delivered(context), do: context

  defp validate_shipping_preferences([], _), do: true

  defp validate_shipping_preferences(packages, selection) do
    # selection must be over all packages, no package can be skipped.
    # TODO: Replace with some nice API contract/validator.
    package_ids =
      packages
      |> Enum.map(fn %{id: id} -> id end)
      |> MapSet.new()

    selection
    |> Enum.map(fn %{package_id: p_id} -> p_id end)
    |> MapSet.new()
    |> MapSet.equal?(package_ids)
  end

  defp fail_fast_reduce(things) do
    Enum.reduce_while(things, {:ok, []}, fn
      {:ok, thing}, {:ok, acc} ->
        {:cont, {:ok, [thing | acc]}}

      {:error, _} = error, _ ->
        {:halt, error}
    end)
  end
end
