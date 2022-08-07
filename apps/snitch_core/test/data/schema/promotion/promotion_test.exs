defmodule Snitch.Data.Schema.PromotionTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory

  alias Snitch.Data.Schema.Promotion

  describe "create_changeset/2" do
    test "fails if required params not present" do
      params = %{}
      changeset = Promotion.create_changeset(%Promotion{}, params)
      assert %{code: ["can't be blank"], name: ["can't be blank"]} = errors_on(changeset)
    end

    test "fails if expiry_at is not in future" do
      params = %{
        code: "OFF5",
        name: "5off",
        expires_at: Timex.shift(DateTime.utc_now(), hours: -2)
      }

      changeset = Promotion.create_changeset(%Promotion{}, params)
      assert %{expires_at: ["date should be in future"]} = errors_on(changeset)
    end

    test "fails if starts_at is after expires_at" do
      params = %{
        code: "OFF5",
        name: "5off",
        starts_at: Timex.shift(DateTime.utc_now(), hours: 3),
        expires_at: Timex.shift(DateTime.utc_now(), hours: 1)
      }

      changeset = Promotion.create_changeset(%Promotion{}, params)

      assert %{
               expires_at: ["expires_at should be after starts_at"]
             } = errors_on(changeset)
    end

    test "fails if match_policy not 'all' or 'any'" do
      params = %{code: "OFF5", name: "5off", match_policy: "ab"}
      changeset = Promotion.create_changeset(%Promotion{}, params)

      assert %{match_policy: ["is invalid"]} = errors_on(changeset)
    end

    test "fails if code is not unique" do
      params = %{code: "OFF5", name: "5off"}
      changeset = Promotion.create_changeset(%Promotion{}, params)

      assert {:ok, _} = Repo.insert(changeset)

      assert {:error, changeset} = Repo.insert(changeset)

      assert %{code: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "update_changeset/2" do
    test "updates successful" do
      params = %{code: "OFF5", name: "5off"}
      changeset = Promotion.create_changeset(%Promotion{}, params)

      assert {:ok, promo} = Repo.insert(changeset)

      update_params = %{name: "christmas sale"}
      changeset = Promotion.update_changeset(promo, update_params)

      assert {:ok, updated_promo} = Repo.update(changeset)
      assert updated_promo.id == promo.id
      assert updated_promo.name != promo.name
    end

    test "fails if error starts_at after expires_at" do
      promotion = insert(:promotion)

      params = %{starts_at: Timex.shift(promotion.expires_at, days: 1)}
      changeset = Promotion.update_changeset(promotion, params)
      assert %{starts_at: ["starts_at should be before expires_at"]} == errors_on(changeset)
    end

    test "fails if error expires_at before starts_at" do
      promotion = insert(:promotion)

      params = %{expires_at: Timex.shift(promotion.starts_at, days: -1)}
      changeset = Promotion.update_changeset(promotion, params)
      assert %{expires_at: ["date should be in future"]} == errors_on(changeset)
    end
  end

  describe "rule_update_changeset/2" do
    test "can successfully add new rules for promotion" do
      promotion = insert(:promotion)

      params = %{
        rules: [
          %{
            name: "Order Item Total",
            module: "Elixir.Snitch.Data.Schema.PromotionRule.OrderTotal",
            preferences: %{lower_range: 10, upper_range: 100}
          },
          %{
            name: "Product Rule",
            module: "Elixir.Snitch.Data.Schema.PromotionRule.Product",
            preferences: %{product_list: [1, 2, 3, 4], match_policy: "all"}
          }
        ]
      }

      promotion = Repo.preload(promotion, :rules)
      assert length(promotion.rules) == 0

      assert %{valid?: true} = cs = Promotion.rule_update_changeset(promotion, params)
      assert {:ok, promo} = Repo.update(cs)
      assert length(promo.rules) == 2
    end

    test "fails if error in any rule" do
      promotion = insert(:promotion)

      params = %{
        rules: [
          %{
            name: "Order Item Total",
            module: "Elixir.Snitch.Data.Schema.PromotionRule.OrderTotal",
            # let's male lower_range string instead of decimal
            preferences: %{lower_range: "abc", upper_range: 100}
          },
          %{
            name: "Product Rule",
            module: "Elixir.Snitch.Data.Schema.PromotionRule.Product",
            # match policy is made any absurd value
            preferences: %{product_list: [1, 2, 3, 4], match_policy: "xyz"}
          }
        ]
      }

      promotion = Repo.preload(promotion, :rules)

      assert %{valid?: false} = cs = Promotion.rule_update_changeset(promotion, params)
      assert {:error, changeset} = Repo.update(cs)

      assert %{
               rules: [
                 %{preferences: [%{lower_range: ["is invalid"]}]},
                 %{preferences: [%{match_policy: ["is invalid"]}]}
               ]
             } = get_changeset_error(changeset)
    end
  end

  describe "action_update_changeset/2" do
    test "can successfully add new actions for promotion" do
      promotion = insert(:promotion)

      params = %{
        actions: [
          %{
            name: "Order Action",
            module: "Elixir.Snitch.Data.Schema.PromotionAction.OrderAction",
            preferences: %{
              calculator_module: "Elixir.Snitch.Domain.Calculator.FlatRate",
              calculator_preferences: %{amount: 10}
            }
          },
          %{
            name: "LineItem Action",
            module: "Elixir.Snitch.Data.Schema.PromotionAction.LineItemAction",
            preferences: %{
              calculator_module: "Elixir.Snitch.Domain.Calculator.FlatRate",
              calculator_preferences: %{amount: 5}
            }
          }
        ]
      }

      promotion = Repo.preload(promotion, :actions)
      assert length(promotion.actions) == 0

      assert %{valid?: true} = cs = Promotion.action_update_changeset(promotion, params)
      assert {:ok, promo} = Repo.update(cs)
      assert length(promo.actions) == 2
    end

    test "fails for errors in params" do
      promotion = insert(:promotion)

      params = %{
        actions: [
          %{
            name: "Order Action",
            module: "Elixir.Snitch.Data.Schema.PromotionAction.OrderAction",
            preferences: %{
              calculator_module: "Elixir.Snitch.Domain.Calculator.FlatRate",
              calculator_preferences: %{amount: "abc"}
            }
          },
          %{
            name: "LineItem Action",
            module: "Elixir.Snitch.Data.Schema.PromotionAction.LineItem",
            preferences: %{
              calculator_module: "Elixir.Snitch.Domain.Calculator.FlatRate",
              calculator_preferences: %{amount: 5}
            }
          }
        ]
      }

      promotion = Repo.preload(promotion, :actions)

      assert %{valid?: false} = cs = Promotion.action_update_changeset(promotion, params)

      assert %{
               actions: [
                 %{preferences: [%{calculator_preferences: [%{amount: ["is invalid"]}]}]},
                 %{module: [%{type: PromotionActionEnum, validation: :cast}]}
               ]
             } = get_changeset_error(cs)
    end
  end

  def get_changeset_error(changeset) do
    traverse_errors(changeset, fn {_msg, opts} ->
      Enum.reduce(opts, %{}, fn {key, value}, acc ->
        Map.put(acc, key, value)
      end)
    end)
  end
end
