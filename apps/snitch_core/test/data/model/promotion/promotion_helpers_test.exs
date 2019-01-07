defmodule Snitch.Data.Model.PromtionHelperTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model.PromotionHelper

  setup do
    promotion = insert(:promotion)
    insert(:product_rule, promotion: promotion)
    insert(:order_total_rule, promotion: promotion)

    [promotion: promotion]
  end

  test "returns a list of promotion rules" do
    rules = PromotionHelper.all_rules()
    rule = List.first(rules)

    assert %{name: _name, module: _module} = rule
  end

  test "return a list of promotion actions" do
    actions = PromotionHelper.all_actions()
    action = List.first(actions)

    assert %{name: _name, module: _module} = action
  end

  test "returns list of all calculators" do
    calculators = PromotionHelper.calculators()
    calculator = List.first(calculators)

    assert %{name: _name, module: _module} = calculator
  end
end
