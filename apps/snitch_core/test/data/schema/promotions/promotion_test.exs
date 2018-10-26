defmodule Snitch.Data.Schema.PromotionTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  alias Snitch.Data.Schema.Promotion

  describe "create_changeset/2" do
    test "create successfully" do
      params = %{code: "INDEPENDENCE"}
      changeset = Promotion.create_changeset(%Promotion{}, params)
      assert changeset.valid?
    end

    test "fails for past expires_at date" do
      params = %{code: "INDEPENDENCE", expires_at: Timex.shift(DateTime.utc_now(), years: -1)}

      changeset = Promotion.create_changeset(%Promotion{}, params)
      assert %{expires_at: ["date should be in future"]} = errors_on(changeset)
    end

    test "for match policy" do
      params = %{
        code: "INDEPENDENCE",
        match_policy: "non-existent"
      }

      changeset = Promotion.create_changeset(%Promotion{}, params)
      assert %{match_policy: ["is invalid"]} = errors_on(changeset)
    end
  end

  describe "rule_update_changeset/2" do
    test "failes for bad name of rule" do
      params = %{
        code: "INDEPENDENCE",
        rules: [
          %{
            name: 1,
            module: Snitch.Data.Schema.PrmotionRule.OrderTotal,
            preferences: %{
              lower_range: "a",
              upper_range: 100
            }
          }
        ]
      }

      changeset = Promotion.rule_update_changeset(%Promotion{}, params)
      assert %{rules: [%{name: ["is invalid"]}]} = errors_on(changeset)
    end
  end
end
