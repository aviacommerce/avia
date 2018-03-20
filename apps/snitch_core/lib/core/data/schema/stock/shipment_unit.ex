defmodule Snitch.Data.Schema.ShipmentUnit do
  @moduledoc """
  Model to track a Package, a part of Shipment.
  """
  use Snitch.Data.Schema
  use Snitch.Data.Schema.Stock

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
  @update_fields ~w(state)a
  @optional_fields ~w(quantity)a

  # defdelegate order_id, to: :shipment

  @doc """
  """
  @spec changeset(__MODULE__, map, atom) :: Ecto.Changeset.t()
  def changeset(instance, params, operation \\ :create)
  def changeset(instance, params, :create), do: do_changeset(instance, params, @create_fields)

  def changeset(instance, params, :update),
    do: do_changeset(instance, params, @update_fields, @optional_fields)

  defp do_changeset(instance, params, fields, optional \\ []) do
    instance
    |> cast(params, fields ++ optional)
    |> validate_required(fields)
    |> validate_number(:quantity, greater_than: -1)
    |> foreign_key_constraint(:line_item_id)
    |> foreign_key_constraint(:variant_id)
  end
end
