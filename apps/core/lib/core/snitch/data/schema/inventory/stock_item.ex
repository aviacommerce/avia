defmodule Core.Snitch.Data.Schema.Inventory.StockItem do
  @moduledoc """
  Model to track inventory
  """
  use Core.Snitch.Data.Schema

  @type t :: %__MODULE__{}

  schema "snitch_stock_items" do
    field(:count_on_hand, :integer, default: 0)

    belongs_to(:variant, Core.Snitch.Variant)
    belongs_to(:stock_location, StockLocation)

    timestamps()
  end

  @create_fields ~w(variant_id stock_location_id count_on_hand)a
  @update_fields ~w(count_on_hand)a
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
    |> foreign_key_constraint(:variant_id)
    |> foreign_key_constraint(:stock_location_id)
    |> validate_number(:count_on_hand, greater_than: -1)
  end
end
