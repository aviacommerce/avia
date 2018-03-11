defmodule Snitch.Data.Schema.StockMovement do
  @moduledoc """
  Model to track inventory movement in between locations
  """
  use Snitch.Data.Schema
  use Snitch.Data.Schema.Stock

  @type t :: %__MODULE__{}

  schema "snitch_stock_movements" do
    field(:quantity, :integer, default: 0)
    field(:action, :string)
    field(:originator_type, :string)
    field(:originator_id, :integer)

    belongs_to(:stock_item, StockItem)

    timestamps()
  end

  @quantity_limits %{min: round(:math.pow(-2, 31)), max: round(:math.pow(2, 31) - 1)}
  @create_fields ~w(quantity stock_item_id)a

  @doc """
  Stock Movements and Stock Transfers are only created.
  Inorder to update them we can create another stock movement to reverse its effects.
  """
  @spec changeset(__MODULE__.t(), map, atom) :: Ecto.Changeset.t()
  def changeset(instance, params, :create), do: do_changeset(instance, params, @create_fields)

  defp do_changeset(instance, params, fields, optional \\ []) do
    instance
    |> cast(params, fields ++ optional)
    |> validate_required(fields)
    |> validate_number(
      :quantity,
      greater_than_or_equal_to: @quantity_limits.min,
      less_than_or_equal_to: @quantity_limits.max
    )
    |> foreign_key_constraint(:stock_item_id)
  end
end
