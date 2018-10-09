defmodule Snitch.Domain.Order do
  @moduledoc """
  Order helpers.
  """

  @editable_states ~w(cart address delivery payment)

  use Snitch.Domain

  import Ecto.Changeset
  import Ecto.Query
  alias Snitch.Data.Schema.{Order, Payment}
  alias Snitch.Data.Model.Product
  alias Snitch.Tools.Defaults
  alias Snitch.Tools.UrlValidator

  @spec validate_change(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_change(%{valid?: false} = changeset), do: changeset

  def validate_change(%{valid?: true} = changeset) do
    prepare_changes(changeset, fn changeset ->
      with {_, order_id} <- fetch_field(changeset, :order_id),
           %Order{state: order_state} <- changeset.repo.get(Order, order_id) do
        if order_state in @editable_states do
          changeset
        else
          add_error(changeset, :order, "has been frozen", validation: :state, state: order_state)
        end
      else
        _ ->
          changeset
      end
    end)
  end

  @doc """
  Returns summation of all the `payments` for the order in the supplied `payment`
  state.
  """
  @spec payments_total(Order.t(), String.t()) :: Money.t()
  def payments_total(order, payment_state) do
    {:ok, currency} = Defaults.fetch(:currency)

    query =
      from(
        payment in Payment,
        where: payment.state == ^payment_state
      )

    order = Repo.preload(order, payments: query)

    order.payments
    |> Enum.reduce(Money.new(currency, 0), fn payment, acc ->
      Money.add!(acc, payment.amount)
    end)
    |> Money.round(currency_digits: :cash)
  end

  @doc """
  Returns the total cost for an `order`.

  The total for an `order` depends on the `state` in which the order is in.

  If the order is in `cart` or the `address` state then total cost is summation
  of individual costs of the lineitems.

  In case the order is in advanced stages like `delivery` or `payment` then the
  summation includes shipment cost, shipping taxes and other taxes on individual
  lineitems as well.
  """
  @spec total_amount(Order.t()) :: Money.t()
  def total_amount(%Order{state: state} = order) when state in ["cart", "address"] do
    order = Repo.preload(order, :line_items)
    line_item_total(order)
  end

  def total_amount(%Order{} = order) do
    order = Repo.preload(order, [:line_items, packages: :items])
    {:ok, currency} = Defaults.fetch(:currency)

    total =
      Money.add!(
        line_item_total(order),
        packages_total_cost(order.packages, currency)
      )

    Money.round(total, currency_digits: :cash)
  end

  def line_item_total(order) do
    {:ok, currency} = Defaults.fetch(:currency)

    order.line_items
    |> Enum.reduce(Money.new(currency, 0), fn line_item, acc ->
      {:ok, total} = Money.mult(line_item.unit_price, line_item.quantity)
      {:ok, acc} = Money.add(acc, total)
      acc
    end)
    |> Money.round(currency_digits: :cash)
  end

  defp packages_total_cost(packages, currency) do
    packages
    |> Enum.reduce(Money.new(currency, 0), fn %{
                                                items: items,
                                                shipping_tax: shipping_tax,
                                                cost: cost
                                              },
                                              acc ->
      acc
      |> Money.add!(shipping_tax)
      |> Money.add!(cost)
      |> Money.add!(package_items_total_cost(items, currency))
    end)
    |> Money.round(currency_digits: :cash)
  end

  # TODO: handle shipping tax for items
  # At present updating taxes for package items on persisting shipping
  # preferences(transition funtction) is not handled.
  defp package_items_total_cost(package_items, currency) do
    Enum.reduce(package_items, Money.new(currency, 0), fn %{shipping_tax: shipping_tax, tax: tax},
                                                          acc ->
      shipping_tax = shipping_tax || Money.new!(currency, 0)

      acc
      |> Money.add!(shipping_tax)
      |> Money.add!(tax)
    end)
  end

  def total_tax(packages) do
    {:ok, currency} = Defaults.fetch(:currency)

    packages
    |> Enum.reduce(Money.new(currency, 0), fn %{
                                                items: items,
                                                shipping_tax: shipping_tax
                                              },
                                              acc ->
      acc
      |> Money.add!(shipping_tax)
      |> Money.add!(package_items_total_cost(items, currency))
    end)
    |> Money.round(currency_digits: :cash)
  end

  def shipping_total(packages) do
    {:ok, currency} = Defaults.fetch(:currency)

    packages
    |> Enum.reduce(Money.new(currency, 0), fn %{cost: cost}, acc ->
      Money.add!(acc, cost)
    end)
    |> Money.round(currency_digits: :cash)
  end

  def fetch_image_url(line_item) do
    image = line_item.product.images |> List.first()
    Product.image_url(image.name, line_item.product)
  end

  def format_date(date) do
    date
    |> NaiveDateTime.to_erl()
    |> form_date
  end

  defp form_date({{year, month, date}, _}) do
    "#{date}/#{month}/#{year}"
  end

  def line_items_count(order) do
    length(order.line_items)
  end

  def order_package_delivered?(order) do
    order = Repo.preload(order, :packages)

    Enum.all?(order.packages, fn package ->
      package.state == "delivered"
    end)
  end
end
