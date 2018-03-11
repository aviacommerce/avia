defmodule Snitch.Data.Schema.StockLocation do
  @moduledoc """
  Model to track inventory
  """
  use Snitch.Data.Schema
  use Snitch.Data.Schema.Stock

  @typedoc """
  ## Field  :propagate_all_variants
  Checking this option when you create a new stock location will
  loop through all of the products you already have in your store,
  and create an entry for each one at your new location, with a
  starting inventory amount of 0.
  """
  @type t :: %__MODULE__{}

  schema "snitch_stock_locations" do
    field(:name, :string)
    # Internal system name
    field(:admin_name, :string)
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

    belongs_to(:state, Snitch.Data.Schema.State)
    belongs_to(:country, Snitch.Data.Schema.Country)

    timestamps()
  end

  @required_fields ~w(name address_line_1 state_id country_id)a
  @opt_update_fields ~w(
      admin_name default address_line_2 city zip_code phone propagate_all_variants
      backorderable_default active
    )a

  def create_fields, do: @create_fields
  def update_fields, do: @update_fields

  @spec changeset(__MODULE__.t(), map, atom) :: Ecto.Changeset.t()
  def changeset(instance, params, _),
    do: do_changeset(instance, params, @required_fields, @opt_update_fields)

  defp do_changeset(instance, params, fields, optional \\ []) do
    instance
    |> cast(params, fields ++ optional)
    |> validate_required(fields)
    |> validate_length(:address_line_1, min: 10)
    |> foreign_key_constraint(:state_id)
    |> foreign_key_constraint(:country_id)
  end
end
