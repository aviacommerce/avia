defmodule Core.Snitch.Data.Schema.CardPayment do
  @moduledoc """
  Models a Payment by credit or debit cards.

  This is a subtype of `Payment`. The record will be deleted if the supertype
  `Payment` is deleted!

  > **On the other hand**, the subtype `CardPayment` can be freely deleted without
    deleting it's supertype `Payment` record.
  """

  use Core.Snitch.Data.Schema

  @type t :: %__MODULE__{}

  schema "snitch_card_payments" do
    field(:response_code, :string)
    field(:response_message, :string)
    field(:avs_response, :string)
    field(:cvv_response, :string)

    belongs_to(:payment, Payment)

    timestamps()
  end

  @required_fields ~w(response_code response_message avs_response cvv_response payment_id)a

  @doc """
  Returns a `CardPayment` changeset.
  """
  @spec changeset(__MODULE__.t(), map(), :create | :update) :: Ecto.Changeset.t()
  def changeset(payment, params, _) do
    payment
    |> cast(params, @required_fields)
    |> unique_constraint(:payment_id)
    |> foreign_key_constraint(:payment_id)
    |> check_constraint(:payment_id, name: :card_exclusivity)
  end
end
