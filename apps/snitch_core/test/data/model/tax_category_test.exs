defmodule Snitch.Data.Model.TaxCategoryTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory
  alias Snitch.Data.Model
  alias Snitch.Data.Schema.TaxCategory

  @valid_params %{
    name: "EU_VAT",
    description: "vat tax",
    tax_code: "EU101"
  }

  describe "create/1" do
    test "tax category successfully" do
      assert {:ok, _} = Model.TaxCategory.create(@valid_params)
    end

    test "fails, Why? name not present" do
      params = Map.drop(@valid_params, [:name])
      assert {:error, cs} = Model.TaxCategory.create(params)
      assert %{name: ["can't be blank"]} = errors_on(cs)
    end

    test "a default tax category" do
      params = Map.put(@valid_params, :is_default?, true)
      assert {:ok, tc} = Model.TaxCategory.create(params)
      assert tc.is_default?
    end

    test "fails, Why? duplicate name" do
      tc = insert(:tax_category)
      params = %{@valid_params | name: tc.name}
      assert {:error, cs} = Model.TaxCategory.create(params)
      assert %{name: ["has already been taken"]} = errors_on(cs)
    end

    test "without conflict with soft deleted tax category" do
      assert {:ok, tc} = Model.TaxCategory.create(@valid_params)
      assert {:ok, _} = Model.TaxCategory.delete(tc)
      assert {:ok, _} = Model.TaxCategory.create(@valid_params)
    end

    test "set a new default, unset older one" do
      params = Map.put(@valid_params, :is_default?, true)
      assert {:ok, tc} = Model.TaxCategory.create(params)
      assert tc.is_default?

      params = Map.put(%{@valid_params | name: "US_VAT"}, :is_default?, true)

      assert {:ok, tc_new} = Model.TaxCategory.create(params)
      assert tc_new.is_default?
      tc_old = Repo.get(TaxCategory, tc.id)
      refute tc_old.is_default?
    end
  end

  describe "update/2" do
    test "successful" do
      tc = insert(:tax_category)
      params = %{name: "US_VAT", tax_code: "US_VAT"}
      assert {:ok, tc_updated} = Model.TaxCategory.update(params, tc)
      assert tc.id == tc_updated.id
      refute tc.name == tc_updated.name
      refute tc.tax_code == tc_updated.tax_code
    end

    test "successful without instance" do
      tc = insert(:tax_category)
      params = %{id: tc.id, name: "US_VAT", tax_code: "US_VAT"}
      assert {:ok, tc_updated} = Model.TaxCategory.update(params)
      assert tc.id == tc_updated.id
      refute tc.name == tc_updated.name
      refute tc.tax_code == tc_updated.tax_code
    end

    test "unsuccessful, Why? name empty" do
      tc = insert(:tax_category)
      params = %{name: "", tax_code: "AU_V"}
      assert {:error, cs} = Model.TaxCategory.update(params, tc)
      assert %{name: ["can't be blank"]} = errors_on(cs)
    end

    test "set new default" do
      params = Map.put(@valid_params, :is_default?, true)
      assert {:ok, tc} = Model.TaxCategory.create(params)
      assert tc.is_default?
      tc_new = insert(:tax_category)
      params = %{is_default?: true}
      assert {:ok, tc_updated} = Model.TaxCategory.update(params, tc_new)
      assert tc_updated.is_default?
      tc_old = Repo.get(TaxCategory, tc.id)
      refute tc_old.is_default?
    end
  end

  describe "delete/1" do
    test "tax category successfully" do
      tc = insert(:tax_category)
      assert {:ok, tc} = Model.TaxCategory.delete(tc)
      refute is_nil(tc.deleted_at)
      tc_deleted = Repo.get(TaxCategory, tc.id)
      refute is_nil(tc_deleted)
    end
  end

  describe "get_all" do
    setup :tax_categories

    @tag tax_category_count: 2
    test "tax categories" do
      tax_categories = Model.TaxCategory.get_all()
      assert length(tax_categories) == 2
      assert {:ok, _} = Model.TaxCategory.delete(List.first(tax_categories))
      tax_categories = Model.TaxCategory.get_all()
      assert length(tax_categories) == 1
    end

    @tag tax_category_count: 2
    test "tax categories including, soft deleted" do
      tax_categories = Model.TaxCategory.get_all()
      assert length(tax_categories) == 2
      assert {:ok, _} = Model.TaxCategory.delete(List.first(tax_categories))
      tax_categories = Model.TaxCategory.get_all(false)
      assert length(tax_categories) == 2
    end

    test "tax categories for no record" do
      Repo.delete_all(TaxCategory)
      tax_categories = Model.TaxCategory.get_all()
      assert tax_categories == []
    end
  end

  describe "get/2" do
    test "tax category" do
      tc = insert(:tax_category)
      tc_ret = Model.TaxCategory.get(tc.id)
      assert tc.id == tc_ret.id
    end

    test "no tax category, is deleted" do
      tc = insert(:tax_category)
      assert {:ok, tc} = Model.TaxCategory.delete(tc)
      refute is_nil(tc.deleted_at)
      tc_ret = Model.TaxCategory.get(tc.id)
      assert is_nil(tc_ret)
    end

    test "tax category, is deleted" do
      tc = insert(:tax_category)
      {:ok, tc} = Model.TaxCategory.delete(tc)
      refute is_nil(tc.deleted_at)
      tc_ret = Model.TaxCategory.get(tc.id, false)
      refute is_nil(tc_ret)
    end
  end
end
