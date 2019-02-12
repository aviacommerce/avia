defmodule Snitch.Data.Model.StockItem do
  @moduledoc """
  This module provides methods or utils for
  Stock Item (alias Inventory at a location)
  by interacting with DB.
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.StockItem, as: StockItemSchema
  alias Snitch.Data.Schema.StockLocation, as: StockLocationSchema

  @spec create(non_neg_integer, non_neg_integer, non_neg_integer, boolean()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create(variant_id, stock_location_id, count_on_hand, backorderable) do
    QH.create(
      StockItemSchema,
      %{
        product_id: variant_id,
        stock_location_id: stock_location_id,
        count_on_hand: count_on_hand,
        backorderable: backorderable
      },
      Repo
    )
  end

  @spec update(non_neg_integer | map, StockItemSchema.t() | nil) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def update(query_fields, instance \\ nil) do
    QH.update(StockItemSchema, query_fields, instance, Repo)
  end

  @spec delete(non_neg_integer | StockItemSchema.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def delete(id_or_instance) do
    QH.delete(StockItemSchema, id_or_instance, Repo)
  end

  @spec get(non_neg_integer | map) :: {:ok, StockItemSchema.t()} | {:error, atom}
  def get(query_fields) do
    QH.get(StockItemSchema, query_fields, Repo)
  end

  @doc """
  Fetches all the stock items present in the DB
  """
  @spec get_all :: list(StockItemSchema.t())
  def get_all, do: Repo.all(StockItemSchema)

  @doc """
  Fetches only the stock items
  that belong to an active stock location
  for a variant
  """
  @spec with_active_stock_location(non_neg_integer) :: list(StockItemSchema.t())
  def with_active_stock_location(variant_id) do
    variant_id
    |> with_active_stock_location_query()
    |> Repo.all()
  end

  @doc """
  Returns a `total available inventory count` for stock items
  present in all active stock locations only.

  The total count can also be negative based on backorderable.
  """
  @spec total_on_hand(non_neg_integer) :: integer
  def total_on_hand(variant_id) do
    stock_items = with_active_stock_location_query(variant_id)
    stock = Repo.one(from(st in stock_items, select: sum(st.count_on_hand)))

    case stock do
      nil -> 0
      stock -> stock
    end
  end

  @doc """
  A query to fetch stock items belonging
  to active stock locations in the DB.

  This can also be used as a subquery.
  ex: stock_items = with_active_stock_location_query(variant_id)
      Repo.one(from(st in stock_items, select: sum(st.count_on_hand)))
  """
  @spec with_active_stock_location_query(integer) :: Ecto.Query.t()
  def with_active_stock_location_query(variant_id) do
    from(
      st in StockItemSchema,
      where: st.product_id == ^variant_id,
      join: sl in StockLocationSchema,
      on: st.stock_location_id == sl.id and sl.active == true
    )
  end

  @doc """
  Returns the stock items for a particular product and stock location
  """
  @spec get_stock(integer, integer) :: [StockItemSchema.t()]
  def get_stock(product_id, stock_location_id) do
    from(
      st in StockItemSchema,
      where: st.product_id == ^product_id and st.stock_location_id == ^stock_location_id,
      select: st
    )
    |> Repo.all()
  end
end
