defmodule Snitch.Data.Schema.LineItem do
  @moduledoc """
  Models a LineItem.
  """

  use Snitch.Data.Schema

  alias Snitch.Data.Schema.{Order, Variant}

  @type t :: %__MODULE__{}

  schema "snitch_line_items" do
    field(:quantity, :integer)
    field(:unit_price, Money.Ecto.Composite.Type)

    belongs_to(:variant, Variant)
    belongs_to(:order, Order)
    timestamps()
  end

  @cast_fields ~w(quantity variant_id unit_price)a
  @update_fields ~w(quantity unit_price)a
  @create_fields [:order_id | @cast_fields]

  @doc """
  Returns a `LineItem` changeset to "cast" a line item via an order changeset.
  """
  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = line_item, params) do
    line_item
    |> cast(params, @cast_fields)
    |> validate_required(@cast_fields)
    |> foreign_key_constraint(:order_id)
    |> foreign_key_constraint(:variant_id)
    |> common_changeset()
  end

  @doc """
  Returns a `LineItem` changeset to insert a new line item.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = line_item, params) do
    line_item
    |> cast(params, @create_fields)
    |> validate_required(@create_fields)
    |> foreign_key_constraint(:order_id)
    |> foreign_key_constraint(:variant_id)
    |> common_changeset()
  end

  @doc """
  Returns a `LineItem` changeset to update the `line_item`.
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = line_item, params) do
    line_item
    |> cast(params, @update_fields)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> validate_number(:quantity, greater_than: 0)
    |> validate_amount(:unit_price)
  end
end
