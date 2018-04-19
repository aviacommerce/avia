defmodule Snitch.Data.Schema.StockTransfer do
  @moduledoc """
  Model to track inventory transfer in location
  """
  use Snitch.Data.Schema
  use Snitch.Data.Schema.Stock

  @type t :: %__MODULE__{}

  schema "snitch_stock_transfers" do
    field(:type, :string)
    field(:reference, :string)
    field(:number, :string)

    belongs_to(:source_location, StockLocation)
    belongs_to(:destination_location, StockLocation)

    timestamps()
  end

  @create_fields ~w(number destination_location_id)a

  def create_fields, do: @create_fields

  @doc """
  Stock Movements and Stock Transfers are only created.
  Inorder to update them we can create another stock movement to reverse its effects.
  """
  @spec changeset(__MODULE__.t(), map, atom) :: Ecto.Changeset.t()
  def changeset(instance, params, operation \\ :create)
  def changeset(instance, params, :create), do: do_changeset(instance, params, @create_fields)

  defp do_changeset(instance, params, fields, optional \\ []) do
    instance
    |> cast(params, fields ++ optional)
    |> validate_required(fields)
    |> foreign_key_constraint(:destination_location_id)
    |> unique_constraint(:slug)
  end
end
