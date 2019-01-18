defmodule Snitch.Data.Model.HostedPayment do
  @moduledoc """
  Hosted Payment API and utilities.

  `HostedPayment` is a concrete payment subtype in Snitch. By `create/4`ing a
  HostedPayment, the supertype Payment is automatically created in the same
  transaction.
  """
  use Snitch.Data.Model

  alias Ecto.Multi
  alias Snitch.Data.Schema.{HostedPayment, Payment}
  alias Snitch.Data.Model.Payment, as: PaymentModel
  alias Snitch.Data.Model.PaymentMethod, as: PaymentMethodModel
  alias SnitchPayments.PaymentMethodCode, as: Codes
  alias Snitch.Core.Tools.MultiTenancy.MultiQuery

  @doc """
  Creates both `Payment` and `HostedPayment` records in a transaction for Order
  represented by `order_id`.

  * `payment_params` are validated using
    `Snitch.Data.Schema.Payment.changeset/3` with the `:create` action and
    because `slug` and `order_id` are passed explicitly to this function,
    they'll be ignored if present in `payment_params`.
  * `hosted_payment_params` are validated using
  `Snitch.Data.Schema.HostedPayment.changeset/3` with the `:create` action.
  """
  @spec create(String.t(), non_neg_integer(), map, map, non_neg_integer()) ::
          {:ok, %{card_payment: HostedPayment.t(), payment: Payment.t()}}
          | {:error, Ecto.Changeset.t()}
  def create(slug, order_id, payment_params, hosted_method_params, payment_method_id) do
    payment = struct(Payment, payment_params)
    {:ok, hosted_method} = PaymentMethodModel.get(payment_method_id)

    more_payment_params = %{
      order_id: order_id,
      payment_type: Codes.hosted_payment(),
      payment_method_id: hosted_method.id,
      slug: slug
    }

    payment_changeset = Payment.create_changeset(payment, more_payment_params)

    Multi.new()
    |> MultiQuery.insert(:payment, payment_changeset)
    |> Multi.run(:hosted_payment, fn %{payment: payment} ->
      hosted_method_params = Map.put(hosted_method_params, :payment_id, payment.id)
      QH.create(HostedPayment, hosted_method_params, Repo)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, data} ->
        {:ok, data}

      {:error, _, error_data, _} ->
        {:error, error_data}
    end
  end

  @doc """
  Updates `HostedPayment` and `Payment` together.

  Everything except the `:payment_type` and `amount` can be changed, because by
  changing the type, `HostedPayment` will have to be deleted.

  * `hosted_method_params` are validated using `HostedPayment.changeset/3` with the
    `:update` action.
  * `payment_params` are validated using `Schema.Payment.changeset/3` with the
    `:update` action.
  """
  @spec update(HostedPayment.t(), map, map) ::
          {:ok, %{card_payment: HostedPayment.t(), payment: Payment.t()}}
          | {:error, Ecto.Changeset.t()}
  def update(hosted_payment, hosted_method_params, payment_params) do
    hosted_payment_changeset =
      HostedPayment.update_changeset(hosted_payment, hosted_method_params)

    Multi.new()
    |> MultiQuery.update(:hosted_payment, hosted_payment_changeset)
    |> Multi.run(:payment, fn _ ->
      PaymentModel.update(nil, Map.put(payment_params, :id, hosted_payment.payment_id))
    end)
    |> Repo.transaction()
    |> case do
      {:ok, data} ->
        {:ok, data}

      {:error, _, error_data, _} ->
        {:error, error_data}
    end
  end

  @doc """
  Fetches the struct but does not preload `:payment` association.
  """
  @spec get(map | non_neg_integer) :: {:ok, HostedPayment.t()} | {:error, atom}
  def get(query_fields_or_primary_key) do
    QH.get(HostedPayment, query_fields_or_primary_key, Repo)
  end

  @spec get_all() :: [HostedPayment.t()]
  def get_all, do: Repo.all(HostedPayment)

  @doc """
  Fetch the HostedPayment identified by the `payment_id`.

  > Note that the `:payment` association is not loaded.
  """
  @spec from_payment(non_neg_integer) :: HostedPayment.t()
  def from_payment(payment_id) do
    {:ok, hosted_payment} = get(%{payment_id: payment_id})
    hosted_payment
  end
end
