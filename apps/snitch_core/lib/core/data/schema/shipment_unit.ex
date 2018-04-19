defmodule Snitch.Data.Schema.ShipmentUnit do
  @moduledoc """
  Model to track a Package, a part of Shipment.
  """
  use Snitch.Data.Schema

  alias Snitch.Data.Schema.{Variant, LineItem}

  @type t :: %__MODULE__{}

  schema "snitch_shipment_units" do
    field(:state, :string)
    field(:quantity, :integer, default: 1)

    belongs_to(:variant, Variant)
    belongs_to(:line_item, LineItem)

    # belongs_to(:order, through: [:shipment_units, :shipment])

    timestamps()
  end

  @create_fields ~w(state quantity line_item_id variant_id)a
  @update_fields ~w(state quantity)a

  @doc """
  Returns a `ShipmentUnit` changeset to create a new shipment_unit.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = shipment_unit, params) do
    shipment_unit
    |> cast(params, @create_fields)
    |> validate_required(@create_fields)
    |> foreign_key_constraint(:line_item_id)
    |> foreign_key_constraint(:variant_id)
    |> common_changeset()
  end

  @doc """
  Returns a `ShipmentUnit` changeset to update the `shipment_unit`.
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = shipment_unit, params) do
    cast(shipment_unit, params, @update_fields)
  end

  defp common_changeset(shipment_unit_changeset) do
    validate_number(shipment_unit_changeset, :quantity, greater_than: -1)
  end
end
