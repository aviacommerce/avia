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

    field(:card_name, :string, virtual: true)
    field(:first_name, :string, virtual: true)
    field(:last_name, :string, virtual: true)
    field(:last_digits, :string, virtual: true)

    belongs_to(:user, User)

    has_many(:card_payments, CardPayment)
    timestamps()
  end

  @required_fields ~w(name_on_card brand user_id month year number)a
  @update_fields ~w(is_disabled)a
  @spec changeset(__MODULE__.t(), map, :create | :update) :: Ecto.Changeset.t()
  def changeset(card, params, action)

  def changeset(card, params, :create) do
    %{year: current_year, month: current_month} = DateTime.utc_now()

    # for now only for VISA cards.

    card
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> build_card
    |> validate_number(
      :month,
      less_than_or_equal_to: 12,
      greater_than_or_equal_to: current_month
    )
    |> validate_number(:year, greater_than_or_equal_to: current_year)
    |> validate_format(:number, ~r/^4[0-9]{12}(?:[0-9]{3})?$/)
    |> foreign_key_constraint(:user_id)
  end

  def changeset(card, params, :update) do
    cast(card, params, @update_fields)
  end

  def build_card(card) do
    card
    |> split_name(Map.has_key?(card.changes, :name_on_card))
    |> extract_last_digits(
      Map.has_key?(card.changes, :card_number),
      Map.has_key?(card.changes, :brand)
    )
  end

  defp split_name(card, true) do
    [first_name | last_name] = String.split(card.changes.name_on_card, " ")
    last_name = List.last(last_name)

    card
    |> put_change(:first_name, first_name)
    |> put_change(:last_name, last_name)
  end

  defp split_name(card, false), do: card

  defp extract_last_digits(card, true, true) do
    card
    |> put_change(:last_digits, String.slice(card.changes.card_number, -4..-1))
    |> put_change(:card_name, "#{card.changes.brand} ending in #{card.changes.last_digits}")
  end

  defp extract_last_digits(card, false, false), do: card
  defp extract_last_digits(card, true, false), do: card
  defp extract_last_digits(card, false, true), do: card
end
