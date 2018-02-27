defmodule Core.Snitch.Data.Model.Payment do
  @moduledoc """
  Payment API and utilities.

  Payment is a polymorphic entity due to the many different kinds of "sources"
  of a payment. Hence, Payments are not a concrete entity in Snitch, and thus
  can be created or updated only by their concrete subtypes.

  To fetch the (associated) concrete subtype, use the convenience utility,
  `to_subtype/1`

  > For a list of supported payment sources, see
    `Core.Snitch.Data.Schema.Payment.PaymentMethod`
  """
  use Core.Snitch.Data.Model

  @deprecated "Deletion of payments! Tsk tsk, bad idea sir/madam"
  @doc """
  Deletes a Payment alongwith the concrete subtype!

  If a `payment` is of type "card", then deleting it will also
  delete the associated entries from "`snitch_card_payments`" table.
  """
  @spec delete(non_neg_integer | Schema.Payment.t()) ::
          {:ok, Schema.Payment.t()} | {:error, Ecto.Changeset.t()} | {:error, :not_found}
  def delete(id_or_instance) do
    QH.delete(Schema.Payment, id_or_instance, Repo)
  end

  @deprecated "This is dangerous as it allows updating the amount"
  @doc """
  Updates an existing `Payment`

  See `Core.Snitch.Data.Schema.Payment.changeset/3` with the `:update` action.
  """
  def update(id_or_instance, params) do
    QH.update(Schema.Payment, params, id_or_instance, Repo)
  end

  @spec get(map | non_neg_integer) :: Schema.Payment.t() | nil | no_return
  def get(query_fields_or_primary_key) do
    QH.get(Schema.Payment, query_fields_or_primary_key, Repo)
  end

  @spec get_all() :: [Schema.Payment.t()]
  def get_all, do: Repo.all(Schema.Payment)

  @doc """
  Fetch the (associated) concrete Payment subtype.

  > Note that the `:payment` association is not loaded.
  """
  @spec to_subtype(non_neg_integer | Schema.Payment.t()) :: struct() | nil
  def to_subtype(id_or_instance)

  def to_subtype(payment_id) when is_integer(payment_id) do
    %{id: payment_id}
    |> get()
    |> to_subtype()
  end

  def to_subtype(payment) when is_nil(payment), do: nil

  def to_subtype(%Schema.Payment{} = payment) do
    case payment.payment_type do
      "ccd" -> Model.CardPayment.from_payment(payment.id)
      "chk" -> payment
    end
  end
end
