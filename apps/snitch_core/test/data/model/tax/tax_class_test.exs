defmodule Snitch.Data.Model.TaxClasstest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model.TaxClass

  describe "create/1" do
    test "creates successfully" do
      params = %{name: "GST_12", is_default: true}
      assert {:ok, _tax_class} = TaxClass.create(params)
    end

    test "fails if default tax class exists" do
      insert(:tax_class, is_default: true)

      params = %{name: "A_GST_25", is_default: true}
      assert {:error, changeset} = TaxClass.create(params)
      assert %{is_default: ["unique default class"]} == errors_on(changeset)
    end

    test "success if default tax class exists" do
      insert(:tax_class, is_default: true)
      params = %{name: "A_GST_25", is_default: false}

      assert {:ok, _data} = TaxClass.create(params)
    end
  end

  describe "update/2" do
    test "successfull" do
      tax_class = insert(:tax_class)
      params = %{name: "GST_12"}

      assert {:ok, data} = TaxClass.update(tax_class, params)
      assert data.id == tax_class.id
      assert data.name != tax_class.name
    end

    test "fails if default upated and other default exists" do
      insert(:tax_class, is_default: true)

      tax_class = insert(:tax_class)
      params = %{name: "GST_12", is_default: true}

      assert {:error, changeset} = TaxClass.update(tax_class, params)
      assert %{is_default: ["unique default class"]} == errors_on(changeset)
    end
  end

  describe "delete/1" do
    test "successful with id" do
      tax_class = insert(:tax_class)
      assert {:ok, _data} = TaxClass.delete(tax_class.id)
    end

    test "successful with instance" do
      tax_class = insert(:tax_class)
      assert {:ok, _data} = TaxClass.delete(tax_class)
    end

    test "fails for non-existent id" do
      error = TaxClass.delete(-1)
      assert {:error, :tax_class_not_found} == error
    end

    test "fails if instance is default" do
      tax_class = insert(:tax_class, is_default: true)
      assert {:error, message} = TaxClass.delete(tax_class)
      assert message == "can not delete default tax class"
    end

    test "fails if associated with another entity" do
      tax_config = insert(:tax_config)
      tax_class_id = tax_config.shipping_tax.id

      assert {:error, message} = TaxClass.delete(tax_class_id)
      assert message == "Tax class associated with some entity, consider removing the association"
    end
  end

  describe "get/1" do
    test "successfully" do
      tax_class = insert(:tax_class)
      assert {:ok, class} = TaxClass.get(tax_class.id)
    end
  end

  describe "get_all" do
    test "returns a list" do
      insert_list(2, :tax_class)

      tax_classes = TaxClass.get_all()
      assert length(tax_classes) == 2
    end
  end

  test "formatted_list/0 returns in format [{tax_class_name, id}]" do
    insert(:tax_class, name: "Shipping Tax")
    insert(:tax_class, name: "Product Tax")
    data = TaxClass.formatted_list()
    assert [{"Product Tax", _}, {"Shipping Tax", _}] = data
  end
end
