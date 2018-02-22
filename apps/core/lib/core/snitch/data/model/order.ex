defmodule Core.Snitch.Data.Model.Order do
  @moduledoc """
  Order API
  """
  use Core.Snitch.Data.Model

  @spec create(map, [map]) :: {:ok, Schema.Order.t()} | {:error, Ecto.Changeset.t()}
  def create(params, line_items) do
    order = struct(Schema.Order, params)
    priced_items = Model.LineItem.update_price_and_totals(line_items)

    order
    |> Schema.Order.create_changeset(Map.put(params, :line_items, priced_items))
    |> Repo.insert()
  end

  @spec update(Schema.Order.t(), map) :: {:ok, Schema.Order.t()} | {:error, Ecto.Changeset.t()}
  def update(order, params) do
    line_items = Map.get(params, :line_items, [])
    priced_items = Model.LineItem.update_price_and_totals(line_items)

    order
    |> Schema.Order.update_changeset(Map.put(params, :line_items, priced_items))
    |> Repo.update()
  end

  @spec delete(non_neg_integer | Schema.Order.t()) ::
          {:ok, Schema.Order.t()} | {:error, Ecto.Changeset.t()}
  def delete(id_or_instance) do
    QH.delete(Schema.Order, id_or_instance, Repo)
  end

  @spec get(map) :: Schema.Order.t() | nil | no_return
  def get(query_fields) do
    QH.get(Schema.Order, query_fields, Repo)
  end

  @spec get_all() :: [Schema.Order.t()]
  def get_all, do: Repo.all(Schema.Order)
end
