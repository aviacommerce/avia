defmodule Core.Snitch.Data.Model.Stock.StockItem do
  @moduledoc """

  """
  use Core.Snitch.Data.Model

  def create(variant_id, stock_location_id, count_on_hand) do
    QH.create(
      Schema.Stock.StockItem,
      %{
        variant_id: variant_id,
        stock_location_id: stock_location_id,
        count_on_hand: count_on_hand
      },
      Repo
    )
  end

  def update(query_fields, instance \\ nil) do
    QH.update(Schema.Stock.StockItem, query_fields, instance, Repo)
  end

  def delete(id_or_instance) do
    QH.delete(Schema.Stock.StockItem, id_or_instance, Repo)
  end

  def get(query_fields) do
    QH.get(Schema.Stock.StockItem, query_fields, Repo)
  end

  def get_all, do: Schema.Stock.StockItem |> Repo.all()
end
