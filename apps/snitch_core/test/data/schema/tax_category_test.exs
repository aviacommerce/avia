defmodule Snitch.Data.Schema.TaxCategoryTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.TaxCategory
  alias Snitch.Core.Tools.MultiTenancy.Repo

  @valid_params %{
    name: "EU_VAT",
    description: "vat tax",
    tax_code: "EU101"
  }

  describe "creation" do
    test "with valid params" do
      changeset =
        %{valid?: validity} = TaxCategory.create_changeset(%TaxCategory{}, @valid_params)

      assert validity
      assert {:ok, _} = Repo.insert(changeset)
    end

    test "as default category" do
      params = Map.put(@valid_params, :is_default?, true)
      changeset = %{valid?: validity} = TaxCategory.create_changeset(%TaxCategory{}, params)
      assert validity
      assert {:ok, tc} = Repo.insert(changeset)
      assert tc.is_default?
    end

    test "fails, Why? duplicate name" do
      tc = insert(:tax_category)
      params = %{@valid_params | name: tc.name}
      changeset = TaxCategory.create_changeset(%TaxCategory{}, params)
      assert {:error, cs} = Repo.insert(changeset)
      assert %{name: ["has already been taken"]} = errors_on(cs)
    end

    test "fails, Why? missing required params" do
      params = Map.drop(@valid_params, [:name])
      changeset = %{valid?: validity} = TaxCategory.create_changeset(%TaxCategory{}, params)
      refute validity
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "updation" do
    test "update category" do
      tc = insert(:tax_category)

      params = %{name: "US_VAT", description: "vat new"}
      cs = %{valid?: validity} = TaxCategory.update_changeset(tc, params)
      assert validity
      {:ok, tc_new} = Repo.update(cs)
      assert tc.id == tc_new.id
      refute tc.name == tc_new.name
      refute tc.description == tc_new.description
    end

    test "fails, duplicate name" do
      tc1 = insert(:tax_category)
      tc2 = insert(:tax_category, %{is_default?: true})
      params = %{name: tc1.name}
      cs = TaxCategory.update_changeset(tc2, params)
      assert {:error, error_cs} = Repo.update(cs)
      assert %{name: ["has already been taken"]} = errors_on(error_cs)
    end
  end
end
