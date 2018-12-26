defmodule SnitchApiWeb.PromotiontControllerTest do
  @moduledoc false

  use SnitchApiWeb.ConnCase, async: true
  import Snitch.Factory
  alias Snitch.Data.Model.Promotion
  alias SnitchApi.{Accounts, Guardian}

  setup %{conn: conn} do
    insert(:role, name: "user")
    user = build(:user_with_no_role)

    conn =
      conn
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, registered_user} = Accounts.create_user(user)
    {:ok, token, _claims} = Guardian.encode_and_sign(registered_user)
    conn = put_req_header(conn, "authorization", "Bearer #{token}")

    {:ok, conn: conn, user: registered_user}
  end

  describe "apply/2" do
    test "successfully applies promotion", %{conn: conn, user: user} do
      item_info = %{quantity: 2, unit_price: Money.new!(currency(), 10)}
      action_manifest = %{order_action: Decimal.new(10), line_item_action: Decimal.new(10)}

      %{order: order, order_total: order_total, product_ids: product_ids} =
        setup_order(item_info, user)

      item_total_cost = Decimal.sub(order_total.amount, 1)

      rule_manifest = %{item_total_cost: item_total_cost, product_ids: product_ids}

      promotion = insert(:promotion)
      set_rules_and_actions(promotion, rule_manifest, action_manifest)

      params = %{
        order_number: order.number,
        promo_code: promotion.code
      }

      return_conn = post(conn, promotion_path(conn, :apply, params))
      data = json_response(return_conn, 200)
      assert data == %{"error" => nil, "message" => "promotion applied", "status" => "success"}
    end

    test "successfully reapply another promotion for order", %{conn: conn, user: user} do
      item_info = %{quantity: 2, unit_price: Money.new!(currency(), 10)}

      %{order: order, order_total: order_total, product_ids: product_ids} =
        order_params = setup_order(item_info, user)

      item_total_cost = Decimal.sub(order_total.amount, 1)

      rule_manifest = %{item_total_cost: item_total_cost, product_ids: product_ids}
      action_manifest = %{order_action: Decimal.new(15), line_item_action: Decimal.new(15)}

      apply_promotion(order_params)

      promotion_other = insert(:promotion, code: "50OFF")
      set_rules_and_actions(promotion_other, rule_manifest, action_manifest)

      params = %{
        order_number: order.number,
        promo_code: promotion_other.code
      }

      conn = post(conn, promotion_path(conn, :apply, params))
      data = json_response(conn, 200)
      assert data == %{"error" => nil, "message" => "promotion applied", "status" => "success"}
    end

    test "does not apply another promotion for order as better one exists", %{
      conn: conn,
      user: user
    } do
      item_info = %{quantity: 2, unit_price: Money.new!(currency(), 10)}

      %{order: order, order_total: order_total, product_ids: product_ids} =
        order_params = setup_order(item_info, user)

      item_total_cost = Decimal.sub(order_total.amount, 1)

      rule_manifest = %{item_total_cost: item_total_cost, product_ids: product_ids}
      action_manifest = %{order_action: Decimal.new(5), line_item_action: Decimal.new(5)}

      apply_promotion(order_params)

      promotion_other = insert(:promotion, code: "50OFF")
      set_rules_and_actions(promotion_other, rule_manifest, action_manifest)

      params = %{
        order_number: order.number,
        promo_code: promotion_other.code
      }

      conn = post(conn, promotion_path(conn, :apply, params))
      data = json_response(conn, 200)

      assert data == %{
               "error" => true,
               "message" => "better promotion already exists",
               "status" => "failed"
             }
    end

    test "fails if the same coupon is applied again", %{conn: conn, user: user} do
      item_info = %{quantity: 2, unit_price: Money.new!(currency(), 10)}
      %{order: order} = order_params = setup_order(item_info, user)

      %{promotion: promotion} = apply_promotion(order_params)

      params = %{
        order_number: order.number,
        promo_code: promotion.code
      }

      conn = post(conn, promotion_path(conn, :apply, params))
      data = json_response(conn, 200)

      assert data == %{
               "error" => true,
               "message" => "coupon already applied",
               "status" => "failed"
             }
    end
  end

  defp apply_promotion(order_params) do
    action_manifest = %{order_action: Decimal.new(10), line_item_action: Decimal.new(10)}
    %{order: order, order_total: order_total, product_ids: product_ids} = order_params

    item_total_cost = Decimal.sub(order_total.amount, 1)

    rule_manifest = %{item_total_cost: item_total_cost, product_ids: product_ids}

    promotion = insert(:promotion)
    set_rules_and_actions(promotion, rule_manifest, action_manifest)

    {:ok, _message} = Promotion.apply(order, promotion.code)

    %{promotion: promotion}
  end

  defp set_rules_and_actions(promotion, rule_manifest, action_manifest) do
    %{item_total_cost: cost, product_ids: product_ids} = rule_manifest
    %{order_action: order_action_data, line_item_action: line_item_action_data} = action_manifest

    insert(:item_total_rule,
      promotion: promotion,
      preferences: %{lower_range: cost, upper_range: Decimal.new(0)}
    )

    insert(:product_rule,
      promotion: promotion,
      preferences: %{match_policy: "all", product_list: product_ids}
    )

    insert(:promotion_order_action,
      preferences: %{
        calculator_module: "Elixir.Snitch.Domain.Calculator.FlatRate",
        calculator_preferences: %{amount: order_action_data}
      },
      promotion: promotion
    )

    insert(:promotion_line_item_action,
      preferences: %{
        calculator_module: "Elixir.Snitch.Domain.Calculator.FlatRate",
        calculator_preferences: %{amount: line_item_action_data}
      },
      promotion: promotion
    )
  end

  defp setup_order(item_info, user) do
    %{quantity: quantity, unit_price: unit_price} = item_info

    products = insert_list(3, :product, promotionable: true)

    order = insert(:order, state: "delivery", user_id: user.id)

    line_items =
      Enum.map(products, fn product ->
        insert(:line_item,
          order: order,
          product: product,
          quantity: quantity,
          unit_price: unit_price
        )
      end)

    cost =
      Enum.reduce(line_items, Money.new!(currency(), 0), fn item, acc ->
        sum = Money.mult!(item.unit_price, item.quantity)
        Money.add!(acc, sum)
      end)

    product_ids = Enum.map(products, fn product -> product.id end)

    %{
      order: order,
      line_items: line_items,
      products: products,
      product_ids: product_ids,
      order_total: cost
    }
  end
end
