defmodule Core.Snitch.Data.Schema.Inventory.StockLocation do
  @moduledoc """
  Model to track inventory
  """
  use Core.Snitch.Data.Schema

  @type t :: %__MODULE__{}

  schema "snitch_stock_locations" do
    field(:name, :string, default: "New Location")

    has_many(:stock_items, StockItem)
    belongs_to(:address, Core.Snitch.Address)

    timestamps()
  end

  @create_fields ~w(name address_id)a
  @update_fields ~w(name)a
  @opt_update_fields []

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
    |> foreign_key_constraint(:address_id)
  end
end
