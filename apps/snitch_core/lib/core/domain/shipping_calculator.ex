defmodule Snitch.Domain.ShippingCalculator do
  @moduledoc """
  Defines the calculator module for shipping.

  The core functionality of the module is to handle
  caluclation of shipping rates.
  """

  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Domain.Order, as: OrderDomain
  alias Snitch.Data.Schema.{Order, Package}

  @defaults Application.get_env(:snitch_core, :defaults_module)

  @doc """
  Returns the `shipping_cost` for a `package`.

  Calculates the cost for the supplied `package`.

  > The supplied `package` should have the `package_items` preloaded.

  The shipping cost is being calculated under the following assumptions:
  - The shipping cost would be calculated for the entire order which can
    consist of multiple packages. However, at present it is being
    assumed that the order will have only one package, so the cost is being
    calcualted for that particular `package`. The supplied `package` may
    change to `order` in future.
  - The different shipping rules are kind of related to different entites.
    e.g. some shipping rules apply to `product`s while some apply to
    `order`s.

  The rules have priority related to them. The priority at present
  is being handled in the `calculate/1`.

  #TODO
  The logic at present is heavily dependent on rules for the shipping category.
  It directly refers to the `shipping_identifier` codes in the logic to do the
  calculation however, it should be modified to make the code more generic.
  At present the code restricts itself to the shipping_identifiers, it may be
  reafactored or rewritten to make it generic.

  The `shipping_cost` is calculated based on some rules. The rules
  are defined for a `shipping_category` by`Snitch.Data.Schema.ShippingRule`.
  """
  @spec calculate(Package.t()) :: Money.t()
  def calculate(package) do
    package =
      Repo.preload(
        package,
        [:items, shipping_category: [shipping_rules: :shipping_rule_identifier]]
      )

    active_rules = get_category_active_rules(package.shipping_category)

    {:ok, currency_code} = @defaults.fetch(:currency)
    cost = Money.new!(currency_code, 0)

    # The piping here is in the order of priority,
    # the lower the function in pipe the higher the priority.
    # Here order rules have higher priority than product rules.
    cost
    |> product_rules_calculator(active_rules, package, currency_code)
    |> order_fixed_rate_calculator(active_rules, package, currency_code)
    |> order_above_limit_price_calculator(active_rules, package, currency_code)
    |> free_shipping(active_rules, package, currency_code)
    |> Money.round()
  end

  # Returns the shipping_rules active for shipping category
  defp get_category_active_rules(shipping_category) do
    Enum.filter(shipping_category.shipping_rules, fn rule ->
      rule.active?
    end)
  end

  defp product_rules_calculator(cost, rules, package, currency_code) do
    get_identifiers = get_rule_identifiers(rules)

    if :fsrp in get_identifiers do
      calculate_cost(:fsrp, package, currency_code, cost)
    else
      cost
    end
  end

  def order_fixed_rate_calculator(cost, rules, package, _currency_code) do
    get_identifiers = get_rule_identifiers(rules)

    if :fiso in get_identifiers do
      shipping_rule = get_rule_for_identifier(package, :fiso)
      shipping_rule.shipping_cost
    else
      cost
    end
  end

  defp order_above_limit_price_calculator(cost, rules, package, currency_code) do
    get_identifiers = get_rule_identifiers(rules)

    if :fsro in get_identifiers do
      calculate_cost(:fsro, package, currency_code, cost)
    else
      cost
    end
  end

  defp free_shipping(cost, rules, _package, currency_code) do
    get_identifiers = get_rule_identifiers(rules)

    if :fso in get_identifiers do
      Money.new!(currency_code, 0)
    else
      cost
    end
  end

  defp get_rule_identifiers(rules) do
    Enum.map(rules, fn rule ->
      rule.shipping_rule_identifier.code
    end)
  end

  ################ functions implementing logic for each identifer ###########

  defp calculate_cost(identifier = :fsrp, package, _currency_code, _prev_cost) do
    shipping_rule = get_rule_for_identifier(package, identifier)

    all_products =
      Enum.reduce(package.items, 0, fn item, acc ->
        acc + item.quantity
      end)

    shipping_rule.shipping_cost
    |> Money.mult!(all_products)
    |> Money.round()
  end

  defp calculate_cost(identifier = :fsro, package, currency_code, prev_cost) do
    shipping_rule = get_rule_for_identifier(package, identifier)
    order = Repo.get(Order, package.order_id) |> Repo.preload(:line_items)
    total_order_cost = OrderDomain.line_item_total(order)

    min_amount = shipping_rule.shipping_cost

    if Money.cmp!(min_amount, total_order_cost) == :lt do
      Money.new!(currency_code, 0)
    else
      prev_cost
    end
  end

  # Returns the shipping_rule by the supplied `identifier`.
  def get_rule_for_identifier(package, identifier) do
    rules = package.shipping_category.shipping_rules

    Enum.find(rules, fn rule ->
      rule.shipping_rule_identifier.code == identifier
    end)
  end
end
