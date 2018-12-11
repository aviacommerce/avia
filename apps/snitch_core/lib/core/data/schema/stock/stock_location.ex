defmodule Snitch.Data.Schema.StockLocation do
  @moduledoc """
  Models a store location or a warehouse where stock is stored, ready to be
  shipped.
  """
  use Snitch.Data.Schema

  alias Snitch.Data.Schema.{Country, State, StockItem}

  @typedoc """
  ## Fields

  1. `:propagate_all_variants`

  If this is set to `true` when creating a new `StockLocation`, then a
  `StockItem` entry with `0` `:count_on_hand` and this `StockLocation` is
  created for all currently existing variants.
  """
  @type t :: %__MODULE__{}

  schema "snitch_stock_locations" do
    field(:name, :string)
    field(:default, :boolean, default: false)

    field(:address_line_1, :string)
    field(:address_line_2, :string)
    field(:city, :string)
    field(:zip_code, :string)
    field(:phone, :string)

    field(:propagate_all_variants, :boolean, default: true)
    field(:backorderable_default, :boolean, default: false)

    field(:active, :boolean, default: true)

    has_many(:stock_items, StockItem)
    has_many(:stock_movements, through: [:stock_items, :stock_movements])

    belongs_to(:state, State)
    belongs_to(:country, Country)

    timestamps()
  end

  @required_fields ~w(name address_line_1 state_id country_id)a
  @cast_fields ~w(address_line_2 city zip_code phone propagate_all_variants)a ++
                 ~w(backorderable_default active)a ++ @required_fields

  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = stock_location, params),
    do: changeset(stock_location, params)

  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = stock_location, params),
    do: changeset(stock_location, params)

  defp changeset(stock_location, params) do
    stock_location
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
    |> validate_length(:address_line_1, min: 10)
    |> validate_format(:phone, ~r/^\d{10}$/)
    |> foreign_key_constraint(:state_id)
    |> foreign_key_constraint(:country_id)
    |> unique_constraint(:name)
  end
end
