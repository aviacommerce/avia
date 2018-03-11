defmodule Snitch.Data.Model.Payment do
  @moduledoc """
  Payment API and utilities.

  Payment is a polymorphic entity due to the many different kinds of "sources"
  of a payment. Hence, Payments are not a concrete entity in Snitch, and thus
  can be created or updated only by their concrete subtypes.

  To fetch the (associated) concrete subtype, use the convenience utility,
  `to_subtype/1`

  > For a list of supported payment sources, see
    `Snitch.Data.Schema.Payment.PaymentMethod`
  """
  use Snitch.Data.Model

  alias Snitch.Data.Schema.Payment
  alias Snitch.Data.Model.CardPayment, as: CardPaymentModel

  @doc """
  Updates an existing `Payment`

  See `Snitch.Data.Schema.Payment.changeset/3` with the `:update` action.
  """
  def update(id_or_instance, params) do
    QH.update(Payment, params, id_or_instance, Repo)
  end

  @spec get(map | non_neg_integer) :: Payment.t() | nil
  def get(query_fields_or_primary_key) do
    QH.get(Payment, query_fields_or_primary_key, Repo)
  end

  @spec get_all() :: [Payment.t()]
  def get_all, do: Repo.all(Payment)

  @doc """
  Fetch the (associated) concrete Payment subtype.

  > Note that the `:payment` association is not loaded.
  """
  @spec to_subtype(non_neg_integer | Payment.t()) :: struct | nil
  def to_subtype(id_or_instance)

  def to_subtype(payment_id) when is_integer(payment_id) do
    %{id: payment_id}
    |> get()
    |> to_subtype()
  end

  def to_subtype(payment) when is_nil(payment), do: nil
  def to_subtype(%Payment{payment_type: "chk"} = payment), do: payment

  def to_subtype(%Payment{payment_type: "ccd"} = payment) do
    CardPaymentModel.from_payment(payment.id)
  end
end
