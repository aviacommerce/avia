defmodule Snitch.Data.Schema.Card do
  use Snitch.Data.Schema

  alias Snitch.Data.Schema.{CardPayment, Address, User}

  @type t :: %__MODULE__{}

  schema "snitch_cards" do
    field(:last_digits, :string)
    field(:name_on_card, :string)
    field(:year, :integer)
    field(:month, :integer)
    field(:card_name, :string)
    field(:brand, :string)
    field(:first_name, :string, virtual: true)
    field(:last_name, :string, virtual: true)

    belongs_to(:address, Address)
    belongs_to(:user, User)

    has_many(:card_payments, CardPayment)
    timestamps()
  end

  @required_fields ~w(last_digits name_on_card brand user_id month year)a
  @optional_fields ~w(card_name address_id)a

  @current_year DateTime.utc_now() |> Map.fetch!(:year)
  @current_month DateTime.utc_now() |> Map.fetch!(:month)

  @spec changeset(__MODULE__.t(), map, :create | :update) :: Ecto.Changeset.t()
  def changeset(card, params, action)

  def changeset(card, params, :create) do
    card
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_number(
      :month,
      less_than_or_equal_to: 12,
      greater_than_or_equal_to: @current_month
    )
    |> validate_number(:year, greater_than_or_equal_to: @current_year)
    |> validate_length(:last_digits, is: 4)
    |> foreign_key_constraint(:address_id)
    |> foreign_key_constraint(:user_id)
  end
end
