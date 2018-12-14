defmodule Snitch.Data.Schema.PromotionTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Snitch.DataCase

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
  end
end
