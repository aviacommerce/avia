defmodule Snitch.Data.Model.StockMovement do
  @moduledoc """
  `StockMovement` API
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.StockMovement, as: StockMovementSchema

  @spec create(integer, String.t()) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create(quantity, stock_item_id) do
    QH.create(
      StockMovementSchema,
      %{
        quantity: quantity,
        stock_item_id: stock_item_id
      },
      Repo
    )
  end

  @spec get(non_neg_integer | map) :: {:ok, StockMovementSchema.t()} | {:error, atom}
  def get(query_fields) do
    QH.get(StockMovementSchema, query_fields, Repo)
  end

  @doc """
  Fetches all the stock items present in the DB
  """
  @spec get_all :: list(StockMovementSchema.t())
  def get_all, do: Repo.all(StockMovementSchema)
end
