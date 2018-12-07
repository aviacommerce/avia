defmodule Snitch.Domain.ShippingCalculator do
  @moduledoc """
  Defines the calculator module for shipping.

  The core functionality of the module is to handle
  caluclation of shipping rates.
  """

  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Model.GeneralConfiguration, as: GCModel
  alias Snitch.Data.Schema.{Package, ShippingRuleIdentifier}

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
    |> Enum.reduce_while(cost, fn rule, acc ->
      code = rule.shipping_rule_identifier.code
      identifier = ShippingRuleIdentifier.identifier_with_module()
      module = identifier[code].module
      module.calculate(package, currency_code, rule, acc)
    end)
    |> Money.round()
  end

  # Returns the shipping_rules active for shipping category
  defp get_category_active_rules(shipping_category) do
    Enum.filter(shipping_category.shipping_rules, fn rule ->
      rule.active?
    end)
  end
end
