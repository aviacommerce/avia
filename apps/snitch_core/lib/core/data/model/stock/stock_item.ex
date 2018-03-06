defmodule Snitch.Data.Model.StockItem do
  @moduledoc """

  """
  use Snitch.Data.Model

  @spec create(non_neg_integer(), non_neg_integer(), non_neg_integer(), boolean()) ::
          TH.commit_response_type()
  def create(variant_id, stock_location_id, count_on_hand, backorderable) do
    QH.create(
      StockItemSchema,
      %{
        variant_id: variant_id,
        stock_location_id: stock_location_id,
        count_on_hand: count_on_hand,
        backorderable: backorderable
      },
      Repo
    )
  end

  @spec update(integer() | map, StockItemSchema.t() | nil) :: TH.commit_response_type()
  def update(query_fields, instance \\ nil) do
    QH.update(StockItemSchema, query_fields, instance, Repo)
  end

  @spec delete(integer() | StockItemSchema.t()) :: TH.commit_response_type()
  def delete(id_or_instance) do
    QH.delete(StockItemSchema, id_or_instance, Repo)
  end

  @spec get(integer() | map) :: StockItemSchema.t()
  def get(query_fields) do
    QH.get(StockItemSchema, query_fields, Repo)
  end

  @doc """
    Fetches all the stock items
  """
  @spec get_all :: list(StockItemSchema.t())
  def get_all, do: StockItemSchema |> Repo.all()

  @doc """
    Fetches only the stock items
    that belong to an active stock location
    for a variant
  """
  @spec stock_items(integer()) :: list(StockItemSchema.t())
  def stock_items(variant_id) do
    variant_id
    |> stock_items_query()
    |> Repo.all()
  end

  @spec total_on_hand(integer()) :: integer()
  def total_on_hand(variant_id) do
    stock_items = stock_items_query(variant_id)
    Repo.one(from(st in stock_items, select: sum(st.count_on_hand)))
  end

  @spec stock_items_query(integer) :: TH.query_type()
  defp stock_items_query(variant_id) do
    from(
      st in StockItemSchema,
      where: st.variant_id == ^variant_id,
      join: sl in StockLocationSchema,
      on: st.stock_location_id == sl.id and sl.active == true
    )
  end
end
