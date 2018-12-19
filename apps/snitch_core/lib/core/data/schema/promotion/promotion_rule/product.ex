defmodule Snitch.Data.Schema.PromotionRule.Product do
  @moduledoc """
  Models the `promotion rule` based on products.

  The rule imposes a condition that a set of products specified by the
  rule are present depending on a preference type:
  - `all' should be present.
  - `any` can be present.
  - `none` should be present.
  """

  use Snitch.Data.Schema
  @behaviour Snitch.Data.Schema.PromotionRule

  @type t :: %__MODULE__{}
  @name "Product Rule"
  @match_policy ~w(all any none)s
  @success_message "product rule applies for order"
  @failure_messsage "product rule fails for the order"

  embedded_schema do
    field(:product_list, {:array, :integer})
    field(:match_policy, :string, default: "any")
  end

  @params ~w(product_list match_policy)a

  def changeset(%__MODULE__{} = data, params) do
    data
    |> cast(params, @params)
    |> validate_length(:product_list, min: 1)
    |> validate_inclusion(:match_policy, @match_policy)
  end

  def rule_name() do
    @name
  end

  @doc """
  Checks if the promotion rule for product is applicable for the supplied
  order.
  Takes as input the order and the list of products, if any of the products
  in the order are present in the supplied product list then the rule is
  satisfied.
  """
  def eligible(order, rule_data) do
    # TODO add logic here.
    order_product_set = get_order_products_set(order)
    rule_product_set = MapSet.new(rule_data["product_list"])

    check_order_against_rule(rule_data["match_policy"], order_product_set, rule_product_set)
  end

  def check_order_against_rule("all", order_products, rule_products) do
    case MapSet.subset?(rule_products, order_products) do
      true ->
        {true, @success_message}

      false ->
        {false, @failure_messsage}
    end
  end

  def check_order_against_rule("any", order_products, rule_products) do
    if MapSet.disjoint?(order_products, rule_products) do
      {false, @failure_messsage}
    else
      {true, @success_message}
    end
  end

  def check_order_against_rule("none", order_products, rule_products) do
    if MapSet.disjoint?(order_products, rule_products) do
      {true, @success_message}
    else
      {false, @failure_messsage}
    end
  end

  defp get_order_products_set(order) do
    order = Repo.preload(order, line_items: [:product])

    products =
      Enum.map(order.line_items, fn item ->
        item.product.id
      end)

    MapSet.new(products)
  end
end
