defmodule Snitch.Data.Schema.StockMovement do
  @moduledoc """
  Records movement of stock (aka. `StockItem`) in between `StockLocation`s.

  `StockMovement`s cannot be updated, though the effect of an existing stock
  movement can be negated by creating its inverse.
  """
  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{StockItem}

  @type t :: %__MODULE__{}

  schema "snitch_stock_movements" do
    field(:quantity, :integer, default: 0)
    field(:action, :string)
    field(:originator_type, :string)
    field(:originator_id, :integer)

    belongs_to(:stock_item, StockItem)

    timestamps()
  end

  @max_abs_quantity round(:math.pow(2, 31))
  @min_limit @max_abs_quantity * -1
  @max_limit @max_abs_quantity - 1

  @required_fields ~w(quantity stock_item_id)a
  @create_fields @required_fields ++ ~w(originator_type originator_type)a

  @doc """
  Returns a `StockMovement` changeset to create a new `stock_movement`.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(stock_movement, params) do
    stock_movement
    |> cast(params, @create_fields)
    |> validate_required(@required_fields)
    |> validate_number(
      :quantity,
      greater_than_or_equal_to: @min_limit,
      less_than_or_equal_to: @max_limit
    )
    |> foreign_key_constraint(:stock_item_id)
  end
end
