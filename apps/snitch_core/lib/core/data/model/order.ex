defmodule Snitch.Data.Model.Order do
  @moduledoc """
  Order API
  """
  use Snitch.Data.Model
  alias Snitch.Data.Schema.Order
  alias Snitch.Data.Model.LineItem, as: LineItemModel

  @spec create(map, [map]) :: {:ok, Order.t()} | {:error, Ecto.Changeset.t()}
  def create(params, line_items) do
    priced_items = update_line_item_costs(line_items)

    QH.create(Order, Map.put(params, :line_items, priced_items), Repo)
  end

  @spec update(map, Order.t()) :: {:ok, Order.t()} | {:error, Ecto.Changeset.t()}
  def update(params, order \\ nil) do
    priced_items =
      params
      |> Map.get(:line_items, [])
      |> update_line_item_costs()

    QH.update(Order, Map.put(params, :line_items, priced_items), order, Repo)
  end

  @spec delete(non_neg_integer | Order.t()) ::
          {:ok, Order.t()} | {:error, Ecto.Changeset.t()} | {:error, :not_found}
  def delete(id_or_instance) do
    QH.delete(Order, id_or_instance, Repo)
  end

  @spec get(map | non_neg_integer) :: Order.t() | nil
  def get(query_fields_or_primary_key) do
    QH.get(Order, query_fields_or_primary_key, Repo)
  end

  @spec get_all() :: [Order.t()]
  def get_all, do: Repo.all(Order)

  defp update_line_item_costs(line_items) when is_list(line_items) do
    unless Enum.empty?(line_items) do
      LineItemModel.update_price_and_totals(line_items)
    else
      line_items
    end
  end
end
