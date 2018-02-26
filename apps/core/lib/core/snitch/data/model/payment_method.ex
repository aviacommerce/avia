defmodule Core.Snitch.Data.Model.PaymentMethod do
  @moduledoc """
  PaymentMethod API and utilities.

  Snitch currently supports the follwoing payment methods:

  ## Debit and Credit cards

  See `Core.Snitch.Data.Model.CardPayment`. Such payments are backed by the
  "`snitch_card_payments"` table that references the `Card` used for payment.

  ## Check or Cash (and cash-on-delivery)

  There's no separate schema for such payments as they are completely expressed
  by the fields in `Core.Snitch.Data.Model.Payment`.
  """
  use Core.Snitch.Data.Model

  @spec create(String.t(), String.t(), boolean()) ::
          {:ok, Schema.PaymentMethod.t()} | {:error, Ecto.Changeset.t()}
  def create(name, <<code::bytes-size(3)>>, is_active? \\ true) do
    pm = %{name: name, code: code, active?: is_active?}
    QH.create(Schema.PaymentMethod, pm, Repo)
  end

  @spec create(map(), Schema.PaymentMethod.t() | nil) ::
          {:ok, Schema.PaymentMethod.t()} | {:error, Ecto.Changeset.t()}
  def update(query_fields, instance \\ nil) do
    QH.update(Schema.PaymentMethod, query_fields, instance, Repo)
  end

  @doc """
  Deletes a PaymentMethod.
  """
  @spec delete(non_neg_integer | Schema.PaymentMethod.t()) ::
          {:ok, Schema.PaymentMethod.t()} | {:error, Ecto.Changeset.t()}
  def delete(id_or_instance) do
    QH.delete(Schema.PaymentMethod, id_or_instance, Repo)
  end

  @spec get(map()) :: Schema.PaymentMethod.t() | nil | no_return
  def get(query_fields) do
    QH.get(Schema.PaymentMethod, query_fields, Repo)
  end

  @spec get_card() :: Schema.PaymentMethod.t() | nil | no_return
  def get_card() do
    get(%{name: "card", code: "ccd"})
  end

  @spec get_check() :: Schema.PaymentMethod.t() | nil | no_return
  def get_check() do
    get(%{name: "check", code: "chk"})
  end

  @spec get_all() :: [Schema.PaymentMethod.t()]
  def get_all, do: Repo.all(Schema.PaymentMethod)
end
