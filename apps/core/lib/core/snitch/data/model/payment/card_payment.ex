defmodule Core.Snitch.Data.Model.CardPayment do
  @moduledoc """
  CardPayment API and utilities.

  `CardPayment` is a concrete payment subtype in Snitch. By `create/2`ing a
  CardPayment, the supertype Payment is automatically created in the same
  transaction.

  > For other supported payment sources, see
    `Core.Snitch.Data.Schema.PaymentMethod`
  """
  use Core.Snitch.Data.Model

  @doc """
  Creates both `Payment` and `CardPayment` records in a transaction.
  """
  @spec create(non_neg_integer(), map()) ::
          {:ok, Schema.CardPayment.t()} | {:error, Ecto.Changeset.t()}
  def create(order_id, params) do
    payment = struct(Schema.Payment, params)
    card_method = Model.PaymentMethod.get_card()
    other_params = %{order_id: order_id, payment_type: "ccd", payment_method_id: card_method.id}
    payment_changeset = Schema.Payment.changeset(payment, other_params, :create)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:payment, payment_changeset)
    |> Ecto.Multi.run(:card_payment, fn %{payment: payment} ->
      QH.create(Schema.CardPayment, %{payment_id: payment.id}, Repo)
    end)
    |> Core.Repo.transaction()
  end

  @deprecated "This is dangerous as it allows changing the amount"
  @doc """
  Updates `CardPayment` and `Payment` together.

  Everything except the `:payment_type` can be changed, because by changing the
  type, `CardPayment` will have to be deleted.

  * `card_params` are validated using `Schema.CardPayment.changeset/3` with the
    `:update` action.
  * `payment_params` are validated using `Schema.Payment.changeset/3` with the
    `:update` action.
  """
  @spec update(Schema.CardPayment.t(), map(), map()) ::
          {:ok, Schema.CardPayment.t()} | {:error, Ecto.Changeset.t()}
  def update(card_payment, card_params, payment_params) do
    card_payment_changeset = Schema.CardPayment.changeset(card_payment, card_params, :update)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:card_payment, card_payment_changeset)
    |> Ecto.Multi.run(:payment, fn _ ->
      Model.Payment.update(payment, payment_params)
    end)
    |> Core.Repo.transaction()
  end

  @deprecated "Deletion of payments! Tsk tsk, bad idea sir."
  @doc """
  Deletes a `CardPayment` alongwith the parent `Payment`!
  """
  @spec delete(non_neg_integer | Schema.CardPayment.t()) ::
          {:ok, Schema.CardPayment.t()} | {:error, Ecto.Changeset.t()}
  def delete(card_payment) when is_map(card_payment) do
    Model.Payment.delete(card_payment.payment_id)
  end

  def delete(card_payment_id) when is_integer(card_payment_id) do
    delete(get(card_payment_id))
  end

  @doc """
  Fetches the struct but does not preload `:payment` association.
  """
  @spec get(map()) :: Schema.CardPayment.t() | nil | no_return
  def get(query_fields) when is_map(query_fields) do
    QH.get(Schema.CardPayment, query_fields, Repo)
  end

  @spec get_all() :: [Schema.CardPayment.t()]
  def get_all, do: Repo.all(Schema.CardPayment)

  @doc """
  Fetch the CardPayment identified by the `payment_id`.

  > Note that the `:payment` association is not loaded.
  """
  @spec from_payment(non_neg_integer) :: Schema.CardPayment.t()
  def from_payment(payment_id) do
    get(%{payment_id: payment_id})
  end
end
