defmodule Snitch.Data.Schema.PromotionRuleTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Schema.PromotionRule

  test "fails for missing params" do
    params = %{}

    changeset = PromotionRule.changeset(%PromotionRule{}, params)

    assert %{
             module: ["can't be blank"],
             name: ["can't be blank"]
           } == errors_on(changeset)
  end

  test "fails for non-existent module" do
    promotion = insert(:promotion)

    params = %{
      name: "Order Item Total",
      module: "AnyModule",
      promotion_id: promotion.id
    }

    changeset = PromotionRule.changeset(%PromotionRule{}, params)
    assert %{module: ["is invalid"]} = errors_on(changeset)
  end

  test "fails if promotion does not exist" do
    params = %{
      name: "Order Item Total",
      module: "Elixir.Snitch.Data.Schema.PromotionRule.ItemTotal",
      preferences: %{lower_range: 10, upper_range: 100},
      promotion_id: -1
    }

    assert %{valid?: true} = cs = PromotionRule.changeset(%PromotionRule{}, params)

    assert {:error, cs} = Repo.insert(cs)
    assert %{promotion_id: ["does not exist"]} == errors_on(cs)
  end

  describe "changeset/2 with 'item total rule'" do
    test "create successfully" do
      promotion = insert(:promotion)

      params = %{
        name: "Order Item Total",
        module: "Elixir.Snitch.Data.Schema.PromotionRule.ItemTotal",
        preferences: %{lower_range: 10, upper_range: 100},
        promotion_id: promotion.id
      }

      assert %{valid?: true} = cs = PromotionRule.changeset(%PromotionRule{}, params)

      assert {:ok, _data} = Repo.insert(cs)
    end

    test "fails for errors on params" do
      promotion = insert(:promotion)

      params = %{
        name: "Order Item Total",
        module: "Elixir.Snitch.Data.Schema.PromotionRule.ItemTotal",
        # upper and lower range need to be decimal values.
        preferences: %{lower_range: "abc", upper_range: "abc"},
        promotion_id: promotion.id
      }

      assert %{valid?: false} = changeset = PromotionRule.changeset(%PromotionRule{}, params)

      assert changeset.errors == [
               preferences:
                 {"invalid_preferences",
                  %{lower_range: ["is invalid"], upper_range: ["is invalid"]}}
             ]
    end
  end

  describe "changeset/2 with 'products rule'" do
    test "create successfully" do
      promotion = insert(:promotion)

      params = %{
        name: "Product Rule",
        module: "Elixir.Snitch.Data.Schema.PromotionRule.Product",
        preferences: %{product_list: [1, 2, 3, 4], match_policy: "all"},
        promotion_id: promotion.id
      }

      assert %{valid?: true} = cs = PromotionRule.changeset(%PromotionRule{}, params)

      assert {:ok, _data} = Repo.insert(cs)
    end

    test "fails for invalid match policy" do
      promotion = insert(:promotion)

      params = %{
        name: "Product Rule",
        module: "Elixir.Snitch.Data.Schema.PromotionRule.Product",
        preferences: %{product_list: [1, 2, 3, 4], match_policy: "abc"},
        promotion_id: promotion.id
      }

      assert %{valid?: false} = cs = PromotionRule.changeset(%PromotionRule{}, params)

      assert cs.errors == [
               preferences: {"invalid_preferences", %{match_policy: ["is invalid"]}}
             ]
    end

    test "fails if product list empty" do
      promotion = insert(:promotion)

      params = %{
        name: "Product Rule",
        module: "Elixir.Snitch.Data.Schema.PromotionRule.Product",
        preferences: %{product_list: [], match_policy: "all"},
        promotion_id: promotion.id
      }

      assert %{valid?: false} = cs = PromotionRule.changeset(%PromotionRule{}, params)

      assert cs.errors == [
               preferences:
                 {"invalid_preferences", %{product_list: ["should have at least 1 item(s)"]}}
             ]
    end
  end
end
