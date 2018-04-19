defmodule Snitch.Data.Schema.Card do
  @moduledoc """
  Models Credit and Debit cards.

  A `User` can save cards by setting the `:card_name`, even if the card is not
  saved, it is associated with the user.
  """

  use Snitch.Data.Schema

  alias Snitch.Data.Schema.{CardPayment, User}

  @typedoc """
  ## `:is_disabled` and `:card_name`

  These fields together decide if the card is listed as a "saved card" to the user.

  | `:is_disabled` | `:card_name`        | Listed as a saved card? |
  |----------------|---------------------|-------------------------|
  | `false`        | **not `nil` or `""` | yes                     |
  | `false`        | `nil` or `""`       | no                      |
  | `true`         | `any`               | no                      |

  ## Note
  A `Card` is never deleted, because `CardPayments` are never deleted.
  """
  @type t :: %__MODULE__{}

  schema "snitch_cards" do
    field(:name_on_card, :string)
    field(:year, :integer)
    field(:month, :integer)
    field(:brand, :string)
    field(:is_disabled, :boolean, default: false)
    field(:number, :string)
    field(:card_name, :string)

    field(:last_digits, :string, virtual: true)
    field(:first_digits, :string, virtual: true)

    belongs_to(:user, User)

    has_many(:card_payments, CardPayment)
    timestamps()
  end

  @required_fields ~w(name_on_card brand user_id month year number)a
  @update_fields ~w(is_disabled card_name)a
  @cast_fields @required_fields ++ @update_fields

  @doc """
  Returns a `Card` changeset.

  The `card_number` should be a string of digits whose length is between 8 to 19
  digits (inclusive), according to [ISO/IEC
  7812](https://www.iso.org/obp/ui/#iso:std:iso-iec:7812:-1:ed-5:v1:en)
  """
  @spec changeset(t, map, :create | :update) :: Ecto.Changeset.t()
  def changeset(card, params, action)

  def changeset(%__MODULE__{} = card, params, :create) do
    %{year: current_year, month: current_month} = DateTime.utc_now()

    card
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
    |> validate_number(
      :month,
      less_than_or_equal_to: 12,
      greater_than_or_equal_to: current_month
    )
    |> validate_number(:year, greater_than_or_equal_to: current_year)
    |> validate_format(:number, ~r/^\d+$/)
    |> validate_length(:number, max: 19, min: 8)
    |> foreign_key_constraint(:user_id)
    |> mask_card
  end

  def changeset(%__MODULE__{} = card, params, :update) do
    cast(card, params, @update_fields)
  end

  defp mask_card(%Ecto.Changeset{} = card_changeset) do
    {:ok, number} = fetch_change(card_changeset, :number)

    card_changeset
    |> put_change(:last_digits, String.slice(number, -4..-1))
    |> put_change(:first_digits, String.slice(number, 0..5))
  end
end
