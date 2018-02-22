defmodule Core.Snitch.Data.Model.Stock.StockLocation do
  @moduledoc """

  """
  use Core.Snitch.Data.Model

  def create(address_id, name) do
    QH.create(
      Schema.Stock.StockLocation,
      %{
        address_id: address_id,
        name: name
      },
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
