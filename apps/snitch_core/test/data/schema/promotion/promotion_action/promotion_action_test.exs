defmodule Snitch.Data.Schema.PromotionActionTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Schema.PromotionAction

  test "fails for missing params" do
    params = %{}

    changeset = PromotionAction.changeset(%PromotionAction{}, params)

    assert %{
             module: ["can't be blank"],
             name: ["can't be blank"]
           } == errors_on(changeset)
  end

  test "fails for non-existent module" do
    promotion = insert(:promotion)

    params = %{
      name: "Order Action",
      module: "AnyModule",
      promotion_id: promotion.id
    }

    changeset = PromotionAction.changeset(%PromotionAction{}, params)
    assert %{module: ["is invalid"]} = errors_on(changeset)
  end

  test "fails if promotion does not exist" do
    params = %{
      name: "Order Action",
      module: "Elixir.Snitch.Data.Schema.PromotionAction.OrderAction",
      preferences: %{
        calculator_module: "Elixir.Snitch.Domain.Calculator.FlatRate",
        calculator_preferences: %{amount: 10}
      },
      promotion_id: -1
    }

    assert %{valid?: true} = cs = PromotionAction.changeset(%PromotionAction{}, params)
    assert {:error, cs} = Repo.insert(cs)
    assert %{promotion_id: ["does not exist"]} == errors_on(cs)
  end

  describe "changeset/2 with 'order action'" do
    test "creates successfully" do
      promotion = insert(:promotion)

      params = %{
        name: "Order Action",
        module: "Elixir.Snitch.Data.Schema.PromotionAction.OrderAction",
        preferences: %{
          calculator_module: "Elixir.Snitch.Domain.Calculator.FlatRate",
          calculator_preferences: %{amount: 10}
        },
        promotion_id: promotion.id
      }

      assert %{valid?: true} = cs = PromotionAction.changeset(%PromotionAction{}, params)
      assert {:ok, _data} = Repo.insert(cs)
    end

    test "fails for errors on params" do
      promotion = insert(:promotion)

      params = %{
        name: "Order Item Total",
        module: "Elixir.Snitch.Data.Schema.PromotionAction.OrderAction",
        # amount needs to be a decimal value
        preferences: %{
          calculator_module: "Elixir.Snitch.Domain.Calculator.FlatRate",
          calculator_preferences: %{amount: "abc"}
        },
        promotion_id: promotion.id
      }

      assert %{valid?: false} = changeset = PromotionAction.changeset(%PromotionAction{}, params)

      assert changeset.errors == [
               preferences:
                 {"invalid_preferences", %{calculator_preferences: [%{amount: ["is invalid"]}]}}
             ]
    end
  end

  describe "changeset/2 with 'line item action'" do
    test "create successfully" do
      promotion = insert(:promotion)

      params = %{
        name: "LineItem Action",
        module: "Elixir.Snitch.Data.Schema.PromotionAction.LineItemAction",
        preferences: %{
          calculator_module: "Elixir.Snitch.Domain.Calculator.FlatRate",
          calculator_preferences: %{amount: 5}
        },
        promotion_id: promotion.id
      }

      assert %{valid?: true} = cs = PromotionAction.changeset(%PromotionAction{}, params)

      assert {:ok, _data} = Repo.insert(cs)
    end

    test "fails for invalid match policy" do
      promotion = insert(:promotion)

      params = %{
        name: "Product Rule",
        module: "Elixir.Snitch.Data.Schema.PromotionAction.LineItemAction",
        preferences: %{
          calculator_module: "Elixir.Snitch.Domain.Calculator.FlatRate",
          calculator_preferences: %{amount: "abc"}
        },
        promotion_id: promotion.id
      }

      assert %{valid?: false} = cs = PromotionAction.changeset(%PromotionAction{}, params)

      assert cs.errors == [
               preferences:
                 {"invalid_preferences", %{calculator_preferences: [%{amount: ["is invalid"]}]}}
             ]
    end
  end
end
