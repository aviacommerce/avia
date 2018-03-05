defmodule Core.Snitch.Data.Schema.Stock.StockLocation do
  @moduledoc false

  use Core.Snitch.Data.Schema

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

    # Checking this option when you create a new stock location will
    # loop through all of the products you already have in your store,
    # and create an entry for each one at your new location, with a
    # starting inventory amount of 0.
    field(:propagate_all_variants, :boolean, default: true)
    field(:backorderable_default, :boolean, default: false)

    field(:active, :boolean, default: true)

    has_many(:stock_items, StockItem)
    belongs_to(:state, Core.Snitch.State)
    belongs_to(:country, Core.Snitch.Country)

    timestamps()
  end

  @create_fields ~w(name address_line_1)a
  @update_fields ~w(name address_line_1)a
  @opt_update_fields ~w(admin_name default address_line_2 city zip_code phone propagate_all_variants backorderable_default active)a

  def create_fields, do: @create_fields
  def update_fields, do: @update_fields

  @spec changeset(__MODULE__.t(), map(), atom) :: Ecto.Changeset.t()
  def changeset(instance, params, operation \\ :create)
  def changeset(instance, params, :create), do: do_changeset(instance, params, @create_fields)

  def changeset(instance, params, :update),
    do: do_changeset(instance, params, @update_fields, @opt_update_fields)

  defp do_changeset(instance, params, fields, optional \\ []) do
    instance
    |> cast(params, fields ++ optional)
    |> validate_required(fields)
    |> validate_length(:address_line_1, min: 10)
    |> foreign_key_constraint(:address_id)
  end
end
