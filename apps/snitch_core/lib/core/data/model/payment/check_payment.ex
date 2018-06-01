defmodule Snitch.Data.Model.CheckPayment do
  @moduledoc """
  CheckPayment API and utilities.

  `CheckPayment` is a concrete payment subtype in Snitch. By `create/4`ing a
  CheckPayment, the supertype Payment is automatically created in the same
  transaction.

  > For other supported payment sources, see
    `Snitch.Data.Schema.PaymentMethod`
  """
  use Snitch.Data.Model

  alias Snitch.Data.Schema.Payment
  alias Snitch.Data.Model.Payment, as: PaymentModel
  alias Snitch.Data.Model.PaymentMethod, as: PaymentMethodModel
  alias Ecto.Multi

  @doc """
  Creates the a "check" `Payment` for Order represented by `order_id`.

  * `payment_params` are validated using
    `Snitch.Data.Schema.Payment.create_changeset/3`.
  """
  @spec create(map) :: {:ok, Payment.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    check_method = PaymentMethodModel.get_check()

    params =
      params
      |> Map.put(:payment_type, "chk")
      |> Map.put(:payment_method_id, check_method.id)

    %Payment{}
    |> Payment.create_changeset(params)
    |> Repo.insert()
  end

  @doc """
  Updates the `check_payment`.

  Everything except the `:payment_type` and `amount` can be changed, because by
  changing the type, `CheckPayment` will have to be deleted.

  * `params` are validated using `Schema.Payment.update_changeset/3`
  """
  @spec update(Payment.t(), map) :: {:ok, Payment.t()} | {:error, Ecto.Changeset.t()}
  def update(check_payment, params) do
    PaymentModel.update(check_payment, params)
  end

  @doc """
  Fetches the `Payment` struct.
  """
  @spec get(map | non_neg_integer) :: Payment.t() | nil
  def get(query_fields_or_primary_key) do
    QH.get(Payment, query_fields_or_primary_key, Repo)
  end

  @spec get_all() :: [Payment.t()]
  def get_all, do: Repo.all(from(p in Payment, where: p.payment_type == "chk"))

  @doc """
  Fetch the CheckPayment identified by the `payment_id`.
  """
  @spec from_payment(non_neg_integer) :: Payment.t()
  def from_payment(payment_id) do
    get(%{id: payment_id, payment_type: "chk"})
  end
end
