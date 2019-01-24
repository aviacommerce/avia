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

  setup :zones
  setup :shipping_methods
  setup :embedded_shipping_methods

  describe "create_changeset/2" do
    test "suuceesfully with valid params, and backorder is computed correctly" do
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

    test "fails for non-existent line_item_id", context do
      %{package: package, product: product, line_item: line_item} = new_package(context)

      params = %{@params | package_id: package.id, product_id: product.id, line_item_id: -1}
      cs = PackageItem.create_changeset(%PackageItem{}, params)
      {:error, changeset} = Repo.insert(cs)
      assert %{line_item_id: ["does not exist"]} == errors_on(changeset)
    end

    test "fails for non-existent product_id", context do
      %{package: package, product: product, line_item: line_item} = new_package(context)

      params = %{@params | package_id: package.id, product_id: -1, line_item_id: line_item.id}
      cs = PackageItem.create_changeset(%PackageItem{}, params)
      {:error, changeset} = Repo.insert(cs)
      assert %{product_id: ["does not exist"]} == errors_on(changeset)
    end

    test "fails for non-existent package_id", context do
      %{package: package, product: product, line_item: line_item} = new_package(context)

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

    test "fails with invalid quantity, delta", context do
      %{package_item: package_item} = make_package_item(context)
      cs = PackageItem.create_changeset(%PackageItem{}, Map.from_struct(package_item))
      refute cs.valid?

      package_item = %{package_item | quantity: -3, delta: -2}
      cs = PackageItem.update_changeset(%PackageItem{}, Map.from_struct(package_item))

      assert %{
               delta: ["must be greater than -1"],
               quantity: ["must be greater than -1"]
             } == errors_on(cs)
    end

    test "fails with invalid and valid tax, shipping tax", context do
      bad_money = Money.new(-1, :USD)
      %{package_item: package_item} = make_package_item(context)
      cs = PackageItem.create_changeset(%PackageItem{}, Map.from_struct(package_item))
      refute cs.valid?

      package_item = %{package_item | tax: bad_money, shipping_tax: bad_money}
      cs = PackageItem.update_changeset(%PackageItem{}, Map.from_struct(package_item))

      assert %{
               shipping_tax: ["must be equal or greater than 0"],
               tax: ["must be equal or greater than 0"]
             } = errors_on(cs)
    end
  end

  defp new_package(context) do
      %{embedded_shipping_methods: embedded_shipping_methods} = context

      country = insert(:country)
      state = insert(:state, country: country)
      stock_location = insert(:stock_location, state: state)
      stock_item = insert(:stock_item, count_on_hand: 10, stock_location: stock_location)
      shipping_category = insert(:shipping_category)

      product = stock_item.product

      order = insert(:order, state: "delivery")

      line_item = insert(:line_item, order: order, product: product, quantity: 3)

      package =
        insert(:package,
          shipping_methods: embedded_shipping_methods,
          order: order,
          items: [],
          origin: stock_item.stock_location,
          shipping_category: shipping_category
        )

        %{package: package, line_item: line_item, product: product}
      end

      defp make_package_item(context) do
        %{package: package, line_item: line_item, product: product} = new_package(context)

          package_item =
            insert(:package_item,
            quantity: 3,
            product: product,
            line_item: line_item,
            package: package
          )

        package = package_item.package
          product = package_item.product
          line_item = package_item.line_item

       %{package_item: package_item}
  end
end
