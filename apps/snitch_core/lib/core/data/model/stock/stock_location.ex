defmodule Snitch.Data.Model.StockLocation do
  @moduledoc """

  """
  use Snitch.Data.Model
  use Snitch.Data.Schema.Stock

  def create(address_id, name) do
    QH.create(
      StockLocation,
      %{
        address_id: address_id,
        name: name
      },
      Repo
    )
  end

  def update(query_fields, instance \\ nil) do
    QH.update(StockLocation, query_fields, instance, Repo)
  end

  def delete(id_or_instance) do
    QH.delete(StockLocation, id_or_instance, Repo)
  end

  def get(query_fields) do
    QH.get(StockLocation, query_fields, Repo)
  end

  def get_all, do: StockLocation |> Repo.all()
end
