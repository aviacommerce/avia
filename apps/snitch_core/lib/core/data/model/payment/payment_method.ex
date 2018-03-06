defmodule Snitch.Data.Model.PaymentMethod do
  @moduledoc """
  PaymentMethod API and utilities.

  Snitch currently supports the following payment methods:

  ## Debit and Credit cards

  See `Snitch.Data.Model.CardPayment`. Such payments are backed by the
  "`snitch_card_payments"` table that references the `Card` used for payment.

  ## Check or Cash (and cash-on-delivery)

  There's no separate schema for such payments as they are completely expressed
  by the fields in `Snitch.Data.Model.Payment`.
  """
  use Snitch.Data.Model

  alias Snitch.Data.Schema

  @spec create(String.t(), String.t(), boolean()) ::
          {:ok, Schema.PaymentMethod.t()} | {:error, Ecto.Changeset.t()}
  def create(name, code, is_active? \\ true) do
    params = %{name: name, code: code, active?: is_active?}
    QH.create(Schema.PaymentMethod, params, Repo)
  end

  @spec update(map, Schema.PaymentMethod.t() | nil) ::
          {:ok, Schema.PaymentMethod.t()} | {:error, Ecto.Changeset.t()}
  def update(query_fields, instance \\ nil) do
    QH.update(Schema.PaymentMethod, query_fields, instance, Repo)
  end

  @doc """
  Deletes a PaymentMethod.
  """
  @spec delete(non_neg_integer | Schema.PaymentMethod.t()) ::
          {:ok, Schema.PaymentMethod.t()} | {:error, Ecto.Changeset.t()} | {:error, :not_found}
  def delete(id_or_instance) do
    QH.delete(Schema.PaymentMethod, id_or_instance, Repo)
  end

  @spec get(map | non_neg_integer) :: Schema.PaymentMethod.t() | nil | no_return
  def get(query_fields_or_primary_key) do
    QH.get(Schema.PaymentMethod, query_fields_or_primary_key, Repo)
  end

  @spec get_card() :: Schema.PaymentMethod.t() | nil | no_return
  def get_card() do
    get(%{code: "ccd"})
  end

  @spec get_check() :: Schema.PaymentMethod.t() | nil | no_return
  def get_check() do
    get(%{code: "chk"})
  end

  @spec get_all() :: [Schema.PaymentMethod.t()]
  def get_all, do: Repo.all(Schema.PaymentMethod)
end
