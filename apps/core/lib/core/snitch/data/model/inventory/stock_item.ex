defmodule Core.Snitch.Data.Model.Inventory.StockItem do
  @moduledoc """

  """
  use Core.Snitch.Data.Model

  def create(variant_id, stock_location_id, count_on_hand) do
    QH.create(
      Schema.Inventory.StockItem,
      %{
        variant_id: variant_id,
        stock_location_id: stock_location_id,
        count_on_hand: count_on_hand
      },
      Repo
    )
  end

  def update(query_fields, instance \\ nil) do
    QH.update(Schema.Inventory.StockItem, query_fields, instance, Repo)
  end

  def delete(id_or_instance) do
    QH.delete(Schema.Inventory.StockItem, id_or_instance, Repo)
  end

  def get(query_fields) do
    QH.get(Schema.Inventory.StockItem, query_fields, Repo)
  end

  def get_all, do: Schema.Inventory.StockItem |> Repo.all()
end
