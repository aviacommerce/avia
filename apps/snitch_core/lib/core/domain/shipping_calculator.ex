defmodule Snitch.Domain.ShippingCalculator do
  @moduledoc """
  Defines the calculator module for shipping.

  The core functionality of the module is to handle
  caluclation of shipping rates.
  """

  @doc """
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

  Out of all the rules that can be activated for a shipping_category, only
  one out of group relating to some entity can be selected.
  Let's say the shipping rules are:
    - **product**
      - flat rate for each product
      - different rate for each product
    - **order**
      - fixed rate for all orders
      - free above some amount for an order

  `Out of the above, one rule can be picked from `product` and, one
  from `order`.

  The rules have priority related to them. The priority at present
  is being handled in the `calculate/1`.

  #TODO
  The logic at present is heavily dependent on rules for the shipping category.
  It directly refers to the `shipping_identifier` codes in the logic to do the
  calculation however, it should be modified to make the code more generic.
  """

  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Domain.Order, as: OrderDomain
  alias Snitch.Data.Schema.{Order, Package, ShippingRuleIdentifier}

  @defaults Application.get_env(:snitch_core, :defaults_module)

  @order_rule_identifiers ShippingRuleIdentifier.order_identifiers()
  @product_rule_identifiers ShippingRuleIdentifier.product_identifier()

  @doc """
  Returns the `shipping_cost` for a `package`.

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
    |> order_rules_calculator(active_rules, package, currency_code)
  end

  # Returns the shipping_rules active for shipping category
  defp get_category_active_rules(shipping_category) do
    Enum.filter(shipping_category.shipping_rules, fn rule ->
      rule.active?
    end)
  end

  defp product_rules_calculator(cost, rules, package, currency_code) do
    get_identifiers = get_rule_identifiers(rules)

    # checks for rule related to product in the supplied `rules`
    dummy_list = @product_rule_identifiers -- get_identifiers

    if @product_rule_identifiers -- dummy_list == [] do
      cost
    else
      [code] = @product_rule_identifiers -- dummy_list

      case code do
        :fsrp ->
          calculate_cost(:fsrp, package, currency_code)

        _ ->
          cost
      end
    end
  end

  defp order_rules_calculator(cost, rules, package, currency_code) do
    get_identifiers = get_rule_identifiers(rules)

    # checks for rule related to order in the supplied `rules`
    dummy_list = @order_rule_identifiers -- get_identifiers

    if @order_rule_identifiers -- dummy_list == [] do
      cost
    else
      [code] = @order_rule_identifiers -- dummy_list

      case code do
        :fsro ->
          calculate_cost(:fsro, package, currency_code)

        :fso ->
          Money.new!(currency_code, 0)
      end
    end
  end

  defp get_rule_identifiers(rules) do
    Enum.map(rules, fn rule ->
      rule.shipping_rule_identifier.code
    end)
  end

  ################ functions implementing logic for each identifer ###########

  defp calculate_cost(identifier = :fsrp, package, _currency_code) do
    shipping_rule = get_rule_for_identifier(package, identifier)

    all_products =
      Enum.reduce(package.items, 0, fn item, acc ->
        acc + item.quantity
      end)

    shipping_rule.shipping_cost
    |> Money.mult!(all_products)
    |> Money.round()
  end

  defp calculate_cost(identifier = :fsro, package, currency_code) do
    shipping_rule = get_rule_for_identifier(package, identifier)
    order = Repo.get(Order, package.order_id) |> Repo.preload(:line_items)
    total_order_cost = OrderDomain.line_item_total(order)

    min_amount = Money.new!(currency_code, shipping_rule.lower_limit)

    if Money.cmp!(min_amount, total_order_cost) == :lt do
      Money.new!(currency_code, 0)
    else
      shipping_rule.shipping_cost
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
