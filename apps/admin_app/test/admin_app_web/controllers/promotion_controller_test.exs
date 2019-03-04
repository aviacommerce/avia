defmodule AdminAppWeb.PromotionControllerTest do
  use AdminAppWeb.ConnCase, async: true
  import Snitch.Factory

  @rule_params [
    %{
      name: "Order Item Total",
      module: "Elixir.Snitch.Data.Schema.PromotionRule.OrderTotal",
      preferences: %{lower_range: Decimal.new(10), upper_range: Decimal.new(100)}
    },
    %{
      name: "Product Rule",
      module: "Elixir.Snitch.Data.Schema.PromotionRule.Product",
      preferences: %{product_list: [1, 2, 3, 4], match_policy: "all"}
    }
  ]

  @action_params [
    %{
      name: "Order Action",
      module: "Elixir.Snitch.Data.Schema.PromotionAction.OrderAction",
      preferences: %{
        calculator_module: "Elixir.Snitch.Domain.Calculator.FlatRate",
        calculator_preferences: %{amount: Decimal.new(10)}
      }
    },
    %{
      name: "LineItem Action",
      module: "Elixir.Snitch.Data.Schema.PromotionAction.LineItemAction",
      preferences: %{
        calculator_module: "Elixir.Snitch.Domain.Calculator.FlatRate",
        calculator_preferences: %{amount: Decimal.new(5)}
      }
    }
  ]

  setup %{conn: conn} do
    role = insert(:role, name: "admin")
    user = insert(:user, role: role)

    conn = signin_guardian(conn, user)
    {:ok, conn: conn}
  end

  describe "index/2" do
    test "returns all the promotions", %{conn: conn} do
      insert(:promotion)
      insert(:promotion, code: "10Off")

      conn = get(conn, promotion_path(conn, :index))
      data = json_response(conn, 200)["data"]

      assert length(data) == 2
    end

    test "does not return promotion if archived", %{conn: conn} do
      insert(:promotion, archived_at: DateTime.to_unix(DateTime.utc_now()))
      insert(:promotion, code: "10Off")

      conn = get(conn, promotion_path(conn, :index))
      data = json_response(conn, 200)["data"]

      assert length(data) == 1
    end
  end

  describe "create/2" do
    test "creates successfully", %{conn: conn} do
      params = %{
        code: "OFF5",
        name: "5off",
        starts_at: Timex.shift(DateTime.utc_now(), hours: 2),
        expires_at: Timex.shift(DateTime.utc_now(), hours: 8),
        rules: @rule_params,
        actions: @action_params,
        description: "5% off on goods."
      }

      params = %{"data" => params}

      conn = post(conn, promotion_path(conn, :create), params)
      data = json_response(conn, 200)

      assert %{"actions" => _actions, "rules" => _rules, "attributes" => _attributes} = data
    end

    test "fails if error on any params", %{conn: conn} do
      [r_param_1, r_param_2] = @rule_params

      rule_params = [
        Map.put(r_param_1, :preferences, %{lower_range: "abc", upper_range: Decimal.new(10)}),
        r_param_2
      ]

      params = %{
        code: 1,
        name: "5off",
        starts_at: Timex.shift(DateTime.utc_now(), hours: 2),
        expires_at: Timex.shift(DateTime.utc_now(), hours: 8),
        rules: rule_params,
        actions: @action_params
      }

      params = %{"data" => params}

      conn = post(conn, promotion_path(conn, :create), params)
      data = json_response(conn, 422)

      assert %{
               "code" => [
                 %{
                   "errors" => %{"type" => "string", "validation" => "cast"},
                   "message" => "is invalid"
                 }
               ],
               "rules" => [
                 %{
                   "preferences" => [
                     %{
                       "errors" => %{"lower_range" => ["is invalid"]},
                       "message" => "invalid_preferences",
                       "name" => "Order Item Total"
                     }
                   ]
                 },
                 %{}
               ]
             } = data["errors"]
    end
  end

  describe "update/2" do
    test "updates successfully", %{conn: conn} do
      promotion = insert(:promotion)
      insert(:order_total_rule, promotion: promotion)
      insert(:promotion_order_action, promotion: promotion)

      params = %{
        data: %{
          code: "10OFF",
          rules: @rule_params
        }
      }

      conn = put(conn, promotion_path(conn, :update, promotion.id), params)
      response = json_response(conn, 200)
      assert response["attributes"]["id"] == promotion.id
      assert response["attributes"]["code"] != promotion.code
    end

    test "fails if promotion archived", %{conn: conn} do
      promotion =
        insert(:promotion,
          archived_at: DateTime.to_unix(DateTime.utc_now())
        )

      insert(:order_total_rule, promotion: promotion)
      insert(:promotion_order_action, promotion: promotion)

      params = %{
        data: %{
          code: "10OFF"
        }
      }

      conn = put(conn, promotion_path(conn, :update, promotion.id), params)
      response = json_response(conn, 422)

      assert %{"error" => %{"message" => "promotion no longer active"}} = response
    end

    test "fails if error on params", %{conn: conn} do
      promotion = insert(:promotion)
      insert(:order_total_rule, promotion: promotion)
      insert(:promotion_order_action, promotion: promotion)

      params = %{
        data: %{
          code: 1
        }
      }

      conn = put(conn, promotion_path(conn, :update, promotion.id), params)
      response = json_response(conn, 422)

      assert %{
               "code" => [
                 %{
                   "errors" => %{"type" => "string", "validation" => "cast"},
                   "message" => "is invalid"
                 }
               ]
             } = response["errors"]
    end
  end

  describe "edit/2" do
    test "get data successfully", %{conn: conn} do
      promotion = insert(:promotion)
      insert(:order_total_rule, promotion: promotion)
      insert(:promotion_order_action, promotion: promotion)

      conn = get(conn, promotion_path(conn, :edit, promotion.id))
      response = json_response(conn, 200)

      assert %{"actions" => _actions, "rules" => _rules, "attributes" => _attributes} = response
    end

    test "fails if id not found", %{conn: conn} do
      conn = get(conn, promotion_path(conn, :edit, -1))
      response = json_response(conn, 401)

      assert %{"message" => "data not found"} = response["error"]
    end
  end

  describe "archive/2" do
    test "archive successfully", %{conn: conn} do
      promotion = insert(:promotion)
      insert(:order_total_rule, promotion: promotion)
      insert(:promotion_order_action, promotion: promotion)

      assert promotion.archived_at == 0

      conn = put(conn, promotion_path(conn, :archive, promotion.id))
      response = json_response(conn, 200)
      assert %{"message" => "promotion archived"} = response
    end
  end

  test "rules/2 returns a list of rules", %{conn: conn} do
    conn = get(conn, promo_rules_path(conn, :rules))
    data = json_response(conn, 200)
    assert data["data"] != []

    rule = List.first(data["data"])
    assert %{"module" => _module, "name" => _name} = rule
  end

  test "actions/2 returns a list of actions", %{conn: conn} do
    conn = get(conn, promo_actions_path(conn, :actions))
    data = json_response(conn, 200)
    assert data["data"] != []

    action = List.first(data["data"])
    assert %{"module" => _module, "name" => _name} = action
  end

  test "rule_preferences/2", %{conn: conn} do
    params = %{
      rule: "Elixir.Snitch.Data.Schema.PromotionRule.Product"
    }

    conn = post(conn, promo_rule_prefs_path(conn, :rule_preferences), params)
    response = json_response(conn, 200)

    assert %{
             "name" => "Elixir.Snitch.Data.Schema.PromotionRule.Product",
             "rule_data" => [
               %{
                 "key" => "product_list",
                 "source" => "/api/product/search",
                 "type" => "multi-select",
                 "value" => nil
               },
               %{
                 "key" => "match_policy",
                 "source" => ["all", "any", "none"],
                 "type" => "select",
                 "value" => nil
               }
             ]
           } = response["data"]
  end

  test "calculator_preferences/2", %{conn: conn} do
    params = %{
      calculator: "Elixir.Snitch.Domain.Calculator.FlatPercent"
    }

    conn = post(conn, promo_calc_prefs_path(conn, :calc_preferences), params)
    response = json_response(conn, 200)

    assert %{
             "data" => [%{"key" => "percent_amount", "type" => "input", "value" => nil}],
             "name" => "Elixir.Snitch.Domain.Calculator.FlatPercent"
           } = response["data"]
  end

  test "action_preferences/2", %{conn: conn} do
    params = %{
      action: "Elixir.Snitch.Data.Schema.PromotionAction.OrderAction"
    }

    conn = post(conn, promo_action_prefs_path(conn, :action_preferences), params)
    response = json_response(conn, 200)

    assert %{
             "action_data" => [
               %{
                 "key" => "calculator_module",
                 "source" => "/promo-calculators",
                 "type" => "select",
                 "value" => nil
               },
               %{"key" => "calculator_preferences", "value" => nil}
             ],
             "name" => "Elixir.Snitch.Data.Schema.PromotionAction.OrderAction"
           } = response["data"]
  end
end
