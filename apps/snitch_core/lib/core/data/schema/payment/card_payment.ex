defmodule Snitch.Data.Schema.CardPayment do
  @moduledoc """
  Models a Payment by credit or debit cards.

  This is a subtype of `Payment`. The record will be deleted if the supertype
  `Payment` is deleted!

  > **On the other hand**, the subtype `CardPayment` can be freely deleted without
    deleting it's supertype `Payment` record.
  """

  use Snitch.Data.Schema

  alias Snitch.Data.Schema.{Card, Payment}

  @type t :: %__MODULE__{}

  schema "snitch_card_payments" do
    field(:response_code, :string)
    field(:response_message, :string)
    field(:avs_response, :string)
    field(:cvv_response, :string)

    belongs_to(:payment, Payment)
    belongs_to(:card, Card)

    timestamps()
  end

  @update_fields ~w(response_code response_message avs_response cvv_response)a
  @create_fields ~w(payment_id card_id)a ++ @update_fields

  @doc """
  Returns a `CardPayment` changeset for a new `card_payment`.

  `:payment_id` is required!
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = card_payment, params) do
    card_payment
    |> cast(params, @create_fields)
    |> assoc_card()
    |> unique_constraint(:payment_id)
    |> foreign_key_constraint(:payment_id)
    |> check_constraint(
      :payment_id,
      name: :card_exclusivity,
      message: "does not refer a card payment"
    )
  end

  @doc """
  Returns a `CardPayment` changeset to update a `card_payment`.

  Note that `:payment_id` cannot be changed, consider deleting this
  `card_payment` instead and creating a new `Snitch.Data.Schema.Payment` as well
  as `Snitch.Data.Schema.CardPayment`.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = card_payment, params) do
    cast(card_payment, params, @update_fields)
  end

  def assoc_card(payment_changeset) do
    case fetch_change(payment_changeset, :card_id) do
      {:ok, _} ->
        foreign_key_constraint(payment_changeset, :card_id)

      :error ->
        cast_assoc(
          payment_changeset,
          :card,
          with: &Card.changeset(&1, &2, :create),
          required: true
        )
    end
  end
end
