defmodule Snitch.Data.Schema.PromotionRule.Product do
  @moduledoc false

  use Snitch.Data.Schema

  alias Snitch.Domain.Order, as: OrderDomain
  alias Snitch.Core.Tools.MultiTenancy.Repo

  embedded_schema do
    field(:product_list, {:array, :float})
  end

  def changeset(%__MODULE__{} = data, params) do
    data
    |> cast(params, [:product])
  end

  @doc """
  Checks if the promotion rule for product is applicable for the supplied
  order.

  Takes as input the order and the list of products, if any of the products
  in the order are present in the supplied product list then the rule is
  satisfied.
  """
  def eligible(order, rule_data) do
    order_products = get_order_products_set(order)
    product_list = MapSet.new(rule_data.product_list)
    # TODO Add better messages
    case MapSet.disjoint?(order_products, product_list) do
      true ->
        {false, "order not eligible, no product found"}

      false ->
        {true, "product present in order"}
    end
  end

  defp get_order_products_set(order) do
    order = Repo.preload(order, packages: [items: :product])

    Enum.reduce(order.packages, MapSet.new([]), fn package, acc ->
      product_list =
        package.items
        |> Enum.map(fn item -> item.product.id end)
        |> MapSet.new()

      MapSet.union(acc, product_list)
    end)
  end
end
