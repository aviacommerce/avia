defmodule Core.Snitch.Data.Model.Order do
  @moduledoc """
  Order API
  """
  use Core.Snitch.Data.Model

  def create(params, line_items) do
    order = struct(Schema.Order, params)
    priced_items = Model.LineItem.update_price_and_totals(line_items)
    
    order
    |> Schema.Order.create_changeset(Map.put(params, :line_items, priced_items))
    |> Repo.insert()
  end

  def update(order, params) do
    line_items = Map.get(params, :line_items, [])
    priced_items = Model.LineItem.update_price_and_totals(line_items)

    order
    |> Schema.Order.update_changeset(Map.put(params, :line_items, priced_items))
    |> Repo.update()
  end

  def delete(id_or_instance) do
    QH.delete(Schema.Order, id_or_instance, Repo)
  end

  def get(query_fields) do
    QH.get(Schema.Order, query_fields, Repo)
  end

  def get_all, do: Schema.Order |> Repo.all()
end
