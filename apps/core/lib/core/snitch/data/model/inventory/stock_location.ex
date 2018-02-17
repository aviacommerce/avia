defmodule Core.Snitch.Data.Model.Inventory.StockLocation do
  @moduledoc """

  """
  use Core.Snitch.Data.Model

  def create(address_id, name) do
    QH.create(
      Schema.Inventory.StockLocation,
      %{
        address_id: address_id,
        name: name
      },
      Repo
    )
  end

  def update(query_fields, instance \\ nil) do
    QH.update(Schema.Inventory.StockLocation, query_fields, instance, Repo)
  end

  def delete(id_or_instance) do
    QH.delete(Schema.Inventory.StockLocation, id_or_instance, Repo)
  end

  def get(query_fields) do
    QH.get(Schema.Inventory.StockLocation, query_fields, Repo)
  end

  def get_all, do: Schema.Inventory.StockLocation |> Repo.all()
end
