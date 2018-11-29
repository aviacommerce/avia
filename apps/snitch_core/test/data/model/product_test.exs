defmodule Snitch.Data.Model.ProductTest do
  use ExUnit.Case
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model.Product
  alias Snitch.Data.Schema.Product, as: ProductSchema
  alias Snitch.Repo

  @rummage_default %{
    "rummage" => %{
      "search" => %{
        "state" => %{"search_expr" => "where", "search_term" => "active", "search_type" => "eq"}
      },
      "sort" => %{"field" => "name", "order" => "asc"}
    }
  }

  setup do
    product = insert(:product)
    shipping_category = insert(:shipping_category)
    taxon = insert(:taxon)

    valid_attrs = %{
      product_id: product.id
    }

    valid_params = %{
      name: "New Product",
      description: "New Product Description",
      slug: "new product slug",
      selling_price: Money.new("12.99", currency()),
      max_retail_price: Money.new("14.99", currency()),
      shipping_category_id: shipping_category.id,
      taxon_id: taxon.id
    }

    [valid_attrs: valid_attrs, valid_params: valid_params]
  end

  describe "get" do
    test "product", %{valid_attrs: va} do
      assert product_returned = Product.get(va.product_id)
      assert product_returned.id == va.product_id
      assert {:ok, _} = Product.delete(va.product_id)
      product_deleted = Product.get(va.product_id)
      assert product_deleted.state == "deleted"
    end

    test "all products" do
      insert(:product)
      assert Product.get_all() != []
    end

    test "products list" do
      insert(:product, state: "active")
      product = Product.get_product_list()
      assert Product.get_product_list() != []
    end

    test "get rummage products list" do
      insert(:product)
      product = Product.get_rummage_product_list(@rummage_default)
      assert Product.get_rummage_product_list(@rummage_default) != []
    end
  end

  describe "get by" do
    test "products with name, state, slug" do
      product = insert(:product)

      assert product_returned =
               Product.get(%{
                 state: product.state,
                 name: product.name,
                 slug: product.slug
               })

      assert product_returned.id == product.id
    end
  end

  describe "create" do
    test "successfully", %{valid_params: vp} do
      assert {:ok, %ProductSchema{}} = Product.create(vp)
    end

    test "creation fails for duplicate product", %{valid_params: vp} do
      Product.create(vp)
      assert {:error, _} = Product.create(vp)
    end
  end

  describe "udpate" do
    test "successfully along with name", %{valid_params: vp} do
      {:ok, product} = Product.create(vp)

      assert {:ok, updated_product} = Product.update(product, %{name: "New Product"})

      assert updated_product.id == product.id
      assert updated_product.name == "New Product"
    end

    test "unsuccessfully along with name empty", %{valid_params: vp} do
      product = insert(:product)

      {:ok, product_new} = Product.create(vp)

      assert {:error, _} =
               Product.update(product_new, %{
                 name: nil
               })
    end
  end

  describe "delete" do
    test "a product" do
      product = insert(:product)
      assert {:ok, _} = Product.delete(product.id)

      product_returned = Repo.get(ProductSchema, product.id)
      assert product_returned != nil
      assert product_returned.state == "deleted"
    end

    test "fails product not found" do
      assert Product.delete(-1) == nil
    end
  end

  describe "selling price" do
    test "for product" do
      product = insert(:product)
      product_selling_price = Product.get_selling_prices([product.id])

      assert %Money{} = Map.get(product_selling_price, product.id)
    end
  end

  describe "is orderable" do
    test "when product with no stock items" do
      product = insert(:product)
      refute Product.is_orderable?(product)
    end

    test "when product with stock items" do
      stock_movement = insert(:stock_movement) |> Repo.preload(stock_item: :product)
      assert Product.is_orderable?(stock_movement.stock_item.product)
    end
  end

  describe "product" do
    test "count by state" do
      taxon = insert(:taxon)
      product = insert(:product)
      {:ok, updated_product} = Product.update(product, %{state: "active", taxon_id: taxon.id})

      next_date =
        product.inserted_at
        |> NaiveDateTime.to_date()
        |> Date.add(1)
        |> Date.to_string()
        |> get_naive_date_time()

      product_state_count =
        Product.get_product_count_by_state(product.inserted_at, next_date) |> List.first()

      assert product_state_count.count == 1
      assert product_state_count.state == "active"
    end
  end

  defp get_naive_date_time(date) do
    Date.from_iso8601(date)
    |> elem(1)
    |> NaiveDateTime.new(~T[00:00:00])
    |> elem(1)
  end
end
