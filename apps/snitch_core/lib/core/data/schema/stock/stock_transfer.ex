defmodule Snitch.Data.Schema.StockTransfer do
  @moduledoc """
  Model to track inventory transfer in location, via `StockMovements`.

  * A `StockTransfer` has many `StockMovement`s via the unique `number`.
  * Both source and destination locations must be set.
  """
  use Snitch.Data.Schema
  use Snitch.Data.Schema.Stock

  @type t :: %__MODULE__{}

  @typedoc """
  ### `:reference`
  This could correlate to a PO number, a transfer request number, a tracking
  number, or any other identifier you wish to use.

  ### `:number`
  A unique human readable identifier for the transfer.
  """

  schema "snitch_stock_transfers" do
    field(:type, :string)
    field(:reference, :string)
    field(:number, :string)

    belongs_to(:source, StockLocation)
    belongs_to(:destination, StockLocation)
    # TODO: may also has_many StockMovements?
    timestamps()
  end

  @required_fields ~w(reference number source_id destination_id)a
  @create_fields [:type | @required_fields]

  @doc """
  Stock Transfers cannot be updated, to reverse/change the effect of a transfer,
  a new one needs to be created.
  """
  @spec changeset(__MODULE__.t(), map, atom) :: Ecto.Changeset.t()
  def changeset(instance, params, operation \\ :create)
  def changeset(instance, params, :create), do: do_changeset(instance, params)

  defp do_changeset(instance, params) do
    instance
    |> cast(params, @create_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:destination_id)
    |> foreign_key_constraint(:source_id)
    |> unique_constraint(:number)
  end
end
