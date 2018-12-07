defmodule Snitch.Domain.ShippingCalculator do
  @moduledoc """
  Defines the calculator module for shipping.

  The core functionality of the module is to handle
  caluclation of shipping rates.
  """

  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Domain.Order, as: OrderDomain
  alias Snitch.Data.Model.GeneralConfiguration, as: GCModel
  alias Snitch.Data.Schema.{Order, Package}

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

    currency_code = GCModel.fetch_currency()
    cost = Money.new!(currency_code, 0)

    active_rules
    |> Enum.reduce_while(cost, fn rule, _acc ->
      code = rule.shipping_rule_identifier.code

      if code == :fsro do
        test = cost_for_above_certain_amount(package, currency_code, rule)
        test
      else
        {:cont, calculate_cost(code, package, currency_code, rule)}
      end
    end)
    |> Money.round()
  end

  # Returns the shipping_rules active for shipping category
  defp get_category_active_rules(shipping_category) do
    Enum.filter(shipping_category.shipping_rules, fn rule ->
      rule.active?
    end)
  end

  defp cost_for_above_certain_amount(package, currency_code, shipping_rule) do
    order = Repo.get(Order, package.order_id) |> Repo.preload(:line_items)
    total_order_cost = OrderDomain.line_item_total(order)

    min_amount = shipping_rule.shipping_cost

    if Money.cmp!(min_amount, total_order_cost) == :lt do
      {:halt, Money.new!(currency_code, 0)}
    else
      {:cont, Money.new!(currency_code, 0)}
    end
  end

  ################ functions implementing logic for each identifer ###########

  defp calculate_cost(_identifier = :fsrp, package, _currency_code, shipping_rule) do
    all_products =
      Enum.reduce(package.items, 0, fn item, acc ->
        acc + item.quantity
      end)

    shipping_rule.shipping_cost
    |> Money.mult!(all_products)
    |> Money.round()
  end

  defp calculate_cost(_identifier = :fso, _package, currency_code, _shipping_rule) do
    Money.new!(currency_code, 0)
  end

  defp calculate_cost(_identifier = :fiso, _package, _currency_code, shipping_rule) do
    shipping_rule.shipping_cost
  end
end
