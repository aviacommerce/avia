defmodule Snitch.Data.Schema.PackageItemTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Ecto.Changeset, only: [fetch_change: 2, apply_changes: 1]
  import Snitch.Factory

  alias Snitch.Data.Schema.PackageItem

  @params %{
    number: "PI01",
    state: "ready",
    quantity: 3,
    delta: 2,
    backordered?: false,
    product_id: 0,
    line_item_id: 0,
    package_id: 0,
    tax: Money.zero(:INR),
    shipping_tax: nil
  }

  setup :product
  setup :line_item
  setup :package
  setup :package_item

  describe "create_changeset/2" do
    test "successfully with valid params, and backorder is computed correctly" do
      assert cs = %{valid?: true} = PackageItem.create_changeset(%PackageItem{}, @params)
      assert {:ok, true} == fetch_change(cs, :backordered?)

      cs = PackageItem.create_changeset(%PackageItem{}, %{@params | delta: 0})
      assert cs.valid?
      assert {:ok, false} == fetch_change(cs, :backordered?)
    end

    test "fails with missing params" do
      cs = PackageItem.create_changeset(%PackageItem{}, %{})
      refute cs.valid?

      assert %{
               line_item_id: ["can't be blank"],
               state: ["can't be blank"],
               product_id: ["can't be blank"],
               tax: ["can't be blank"]
             } == errors_on(cs)
    end

    test "fails for non-existent line_item_id, product_id and package_id", context do
      %{package: package, product: product, line_item: line_item} = context

      params = %{@params | package_id: package.id, product_id: product.id, line_item_id: -1}
      cs = PackageItem.create_changeset(%PackageItem{}, params)
      {:error, changeset} = Repo.insert(cs)
      assert %{line_item_id: ["does not exist"]} == errors_on(changeset)

      params = %{@params | package_id: package.id, product_id: -1, line_item_id: line_item.id}
      cs = PackageItem.create_changeset(%PackageItem{}, params)
      {:error, changeset} = Repo.insert(cs)
      assert %{product_id: ["does not exist"]} == errors_on(changeset)

      params = %{@params | package_id: -1, product_id: product.id, line_item_id: line_item.id}
      cs = PackageItem.create_changeset(%PackageItem{}, params)
      {:error, changeset} = Repo.insert(cs)
      assert %{package_id: ["does not exist"]} == errors_on(changeset)
    end

    test "fails with invalid quantity, delta" do
      cs = PackageItem.create_changeset(%PackageItem{}, %{@params | quantity: -2, delta: -1})
      refute cs.valid?

      assert %{
               delta: ["must be greater than -1"],
               quantity: ["must be greater than -1"]
             } = errors_on(cs)
    end

    test "fails with invalid tax, shipping_tax" do
      bad_money = Money.new(-1, :USD)

      cs =
        PackageItem.create_changeset(%PackageItem{}, %{
          @params
          | tax: bad_money,
            shipping_tax: bad_money
        })

      assert %{
               shipping_tax: ["must be equal or greater than 0"],
               tax: ["must be equal or greater than 0"]
             } = errors_on(cs)
    end
  end

  describe "update_changeset/2" do
    test "successful with valid params, and backorder is computed correctly" do
      assert cs = %{valid?: true} = PackageItem.create_changeset(%PackageItem{}, @params)
      package_item = apply_changes(cs)
      params = %{state: "destroyed", quantity: 0, delta: 3, backordered?: false}

      assert cs = %{valid?: true} = PackageItem.update_changeset(package_item, params)

      assert :error = fetch_change(cs, :backordered?)
      assert {:ok, "destroyed"} = fetch_change(cs, :state)
      assert {:ok, 3} = fetch_change(cs, :delta)
      assert {:ok, 0} = fetch_change(cs, :quantity)

      assert cs =
               %{valid?: true} =
               PackageItem.update_changeset(package_item, %{
                 state: "destroyed",
                 quantity: 2,
                 delta: 0
               })

      assert {:ok, false} = fetch_change(cs, :backordered?)
    end

    test "fails with invalid quantity, delta", %{package_item: package_item} do
      params = %{quantity: -3, delta: -2}
      cs = PackageItem.update_changeset(package_item, params)

      assert %{
               delta: ["must be greater than -1"],
               quantity: ["must be greater than -1"]
             } == errors_on(cs)
    end

    test "fails with invalid and valid tax, shipping tax", %{package_item: package_item} do
      bad_money = Money.new(-1, :USD)
      params = %{tax: bad_money, shipping_tax: bad_money}
      cs = PackageItem.update_changeset(package_item, params)

      assert %{
               shipping_tax: ["must be equal or greater than 0"],
               tax: ["must be equal or greater than 0"]
             } == errors_on(cs)
    end
  end

  defp product(_context) do
    product = insert(:product)
    [product: product]
  end

  defp line_item(_context) do
    line_item = insert(:line_item)
    [line_item: line_item]
  end

  defp package(_context) do
    package = insert(:package)
    [package: package]
  end

  defp package_item(context) do
    %{package: package} = context
    package_item = insert(:package_item, package: package)
    [package_item: package_item]
  end
end
