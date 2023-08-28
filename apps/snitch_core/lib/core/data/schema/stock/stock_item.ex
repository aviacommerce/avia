defmodule Snitch.Data.Schema.StockItem do
  @moduledoc """
  StockItem tracks the store's inventory.
  """
  use Snitch.Data.Schema

  alias Snitch.Data.Schema.{StockLocation, Product, Variant}

  @type t :: %__MODULE__{}

  schema "snitch_stock_items" do
    field(:count_on_hand, :integer, default: 0)
    field(:inventory_warning_level, :integer, default: 0)
    field(:backorderable, :boolean, default: false)

    belongs_to(:product, Product)
    belongs_to(:stock_location, StockLocation)
    belongs_to(:variant, Variant)

    timestamps()
  end

  @create_fields ~w(product_id stock_location_id count_on_hand)a
  @update_fields ~w(count_on_hand inventory_warning_level)a

  @doc """
  Returns a `StockItem` changeset to create a new `stock_item`.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = stock_item, params) do
    stock_item
    |> cast(params, @create_fields)
    |> validate_required(@create_fields)
    |> common_changeset()
  end

  @doc """
  Returns a `StockItem` changeset to update `stock_item`.
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = stock_item, params) do
    stock_item
    |> cast(params, @update_fields)
    |> common_changeset()
  end

  defp common_changeset(stock_item_changeset) do
    stock_item_changeset
    |> validate_number(:count_on_hand, greater_than: -1)
    |> foreign_key_constraint(:product_id)
    |> foreign_key_constraint(:stock_location_id)
  end
end
