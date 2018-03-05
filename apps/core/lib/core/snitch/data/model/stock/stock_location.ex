defmodule Core.Snitch.Data.Model.Stock.StockLocation do
  @moduledoc false
  use Core.Snitch.Data.Model

  def create(attrbutes) do
    QH.create(
      Schema.Stock.StockLocation,
      attrbutes,
      Repo
    )
  end

  def update(query_fields, instance \\ nil) do
    QH.update(Schema.Stock.StockLocation, query_fields, instance, Repo)
  end

  def delete(id_or_instance) do
    QH.delete(Schema.Stock.StockLocation, id_or_instance, Repo)
  end

  def get(query_fields) do
    QH.get(Schema.Stock.StockLocation, query_fields, Repo)
  end

  def get_all, do: Schema.Stock.StockLocation |> Repo.all()
end
