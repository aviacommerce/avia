defmodule Snitch.Data.Schema.Card do
  use Snitch.Data.Schema

  alias Snitch.Data.Schema.{CardPayment, User}

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
    field(:first_six_digits, :string, virtual: true)

    belongs_to(:user, User)

    has_many(:card_payments, CardPayment)
    timestamps()
  end

  @required_fields ~w(name_on_card brand user_id month year number)a
  @optional_fields ~w(card_name)a
  @update_fields ~w(is_disabled card_name)a

  @cast_fields @required_fields ++ @optional_fields ++ @update_fields
  @spec changeset(__MODULE__.t(), map, :create | :update) :: Ecto.Changeset.t()
  def changeset(card_changeset, params, action)

  def changeset(card_changeset, params, :create) do
    %{year: current_year, month: current_month} = DateTime.utc_now()

    card_changeset
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
    |> validate_number(
      :month,
      less_than_or_equal_to: 12,
      greater_than_or_equal_to: current_month
    )
    |> validate_number(:year, greater_than_or_equal_to: current_year)
    |> validate_format(:number, ~r/^\d{16}$/)
    |> foreign_key_constraint(:user_id)
    |> mask_card
  end

  def changeset(card_changeset, params, :update) do
    cast(card_changeset, params, @update_fields)
  end

  def mask_card(card_changeset) do
    if Map.has_key?(card_changeset.changes, :card_number) do
      card_changeset
      |> put_change(:last_digits, String.slice(card_changeset.changes.card_number, -4..-1))
      |> put_change(:first_six_digits, String.slice(card_changeset.changes.card_number, 0..5))
    else
      card_changeset
    end
  end
end
