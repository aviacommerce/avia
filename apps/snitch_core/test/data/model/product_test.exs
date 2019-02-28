defmodule Snitch.Data.Model.ProductTest do
  use ExUnit.Case
  use Snitch.DataCase
  import Snitch.Factory
  import Mock
  alias Snitch.Data.Model.Product
  alias Snitch.Tools.GenNanoid
  alias Snitch.Data.Schema.Product, as: ProductSchema
  alias Snitch.Data.Schema.{Variation, Image}
  alias Snitch.Tools.Helper.Taxonomy
  alias NanoidMock
  alias Snitch.Domain.Taxonomy, as: TaxonomyDomain
  alias Snitch.Repo

  @rummage_default %{
    "rummage" => %{
      "search" => %{
        "state" => %{"search_expr" => "where", "search_term" => "active", "search_type" => "eq"}
      },
      "sort" => %{"field" => "name", "order" => "asc"}
    }
  }

  @img "test/support/image.png"
  @img_new "test/support/image_new.png"

  setup do
    product = insert(:product)
    shipping_category = insert(:shipping_category)
    taxon = insert(:taxon)

    valid_attrs = %{
      product_id: product.id
    }

    image_params = %{
      "images" => [
        %{
          "image" => %{
            filename: "fDwvoPbZGc4WuAVLYwwyo.png",
            path: @img,
            type: "image/png",
            url: "/abc"
          }
        }
      ]
    }

    tax_class = insert(:tax_class)

    valid_params = %{
      name: "New Product",
      description: "New Product Description",
      slug: "new product slug",
      selling_price: Money.new("12.99", currency()),
      max_retail_price: Money.new("14.99", currency()),
      shipping_category_id: shipping_category.id,
      taxon_id: taxon.id,
      tax_class_id: tax_class.id
    }

    [valid_attrs: valid_attrs, valid_params: valid_params, image_params: image_params]
  end

  describe "product relation" do
    setup do
      attrs = %{products: [build(:variant)]}
      parent_product = insert(:product, attrs)
      variant = parent_product.products |> List.first()
      [parent_product: parent_product, variant: variant]
    end

    test "if it is a parent", %{parent_product: parent_product} do
      is_parent = Product.is_parent_product(to_string(parent_product.id))
      assert is_parent == true
    end

    test "if it is a child", %{variant: variant} do
      is_child = Product.is_child_product(variant)
      assert is_child == true
    end

    test "if it is neither child nor parent" do
      product = insert(:product)
      is_child = Product.is_child_product(product)
      is_parent = Product.is_parent_product(to_string(product.id))
      assert is_child == false
      assert is_parent == true
    end
  end

  describe "get" do
    test "product", %{valid_attrs: va} do
      assert {:ok, product_returned} = Product.get(va.product_id)
      assert product_returned.id == va.product_id
      assert {:ok, _} = Product.delete(va.product_id)
      {:ok, product_deleted} = Product.get(va.product_id)
      assert product_deleted.state == :deleted
    end

    test "all products" do
      insert(:product)
      assert Product.get_all() != []
    end

    test "products list" do
      insert(:product, state: :active)
      product = Product.get_product_list()
      assert Product.get_product_list() != []
    end

    test "get rummage products list" do
      insert(:product)
      product = Product.get_rummage_product_list(@rummage_default)
      assert Product.get_rummage_product_list(@rummage_default) != []
    end
  end

  describe "test get product with default image" do
    test "having default image set" do
      attrs = %{images: [build(:image)]}
      product = insert(:product, attrs)
      product_returned = Product.get_product_with_default_image(product)
      image = product_returned.images |> List.first()
      assert product_returned.id == product.id
      assert image.is_default == true
    end

    test "having default image not set" do
      attrs = %{is_default: false}
      image = %{images: [build(:image, attrs)]}
      product = insert(:product, image)
      product_returned = Product.get_product_with_default_image(product)
      image = product_returned.images |> List.first()
      assert product_returned.id == product.id
      assert image == nil
    end
  end

  describe "get by" do
    test "products with name, state, slug" do
      product = insert(:product)

      assert {:ok, product_returned} =
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
  end

  test "upi generation for a product", %{valid_params: vp} do
    with_mock GenNanoid, gen_nano_id: fn -> NanoidMock.gen_nano_id() end do
      NanoidMock.start_link(0)

      {:ok, product1} = Product.create(vp)
      vp = %{vp | name: "latest test product"}
      {:ok, product2} = Product.create(vp)

      assert product1.upi == "A0C"
      refute product1.upi == product2.upi

      NanoidMock.stop()
    end
  end

  describe "test return upi function" do
    setup do
      product = insert(:product)
      [product: product]
    end

    test "if the upi has already been assigned to a product", %{product: product} do
      upi = product.upi
      assert Product.get_upi_if_unique(upi) == {:error, "not_unique"}
    end

    test "if a non existing product upi is passed as an argument", %{product: product} do
      upi = "AMDQMQRZ59OC"
      assert Product.get_upi_if_unique(upi) == {:ok, upi}
    end
  end

  describe "sellable products list" do
    test "if product has no variants" do
      assert [%ProductSchema{}] = Product.sellable_products_query() |> Repo.all()
    end

    test "if product has variants" do
      attrs = %{products: [build(:variant)]}
      product = insert(:product, attrs)
      variant = product.products |> List.first()
      variation = insert(:variation, %{parent_product: product, child_product: variant})

      sellable_products = Product.sellable_products_query() |> Repo.all() |> Enum.map(& &1.id)
      assert Enum.member?(sellable_products, variant.id) == true
      refute Enum.member?(sellable_products, product.id)
    end
  end

  describe "image handling - " do
    setup do
      product = insert(:product)
      taxon = insert(:taxon)
      {:ok, updated_product} = Product.update(product, %{state: :active, taxon_id: taxon.id})
      product = updated_product |> Repo.preload(:images)
      [product: product]
    end

    test "add images with valid params", %{image_params: ip, product: product} do
      assert {:ok, %ProductSchema{} = product} = Product.add_images(product, ip)
    end

    test "delete image for a product", %{product: product, image_params: ip} do
      Product.add_images(product, ip)
      new_product = product |> Repo.preload(:images, force: true)
      image = new_product.images |> List.first()
      assert {:ok, "success"} = Product.delete_image(new_product.id, image.id)
    end

    test "pass empty list of images to a product" do
      product = insert(:product) |> Repo.preload(:images)
      ip = %{"images" => []}
      assert {:error, _} = Product.add_images(product, ip)
    end

    test "set default image", %{image_params: ip, product: product} do
      [ok: %Image{is_default: true} = image, ok: %Image{}] = update_default_image(ip, product)
      assert image.is_default == true
    end
  end

  defp update_default_image(ip, product) do
    images = [
      %{
        "image" => %{
          filename: "AfddfPbZGc4WuAVLYwwyo.png",
          path: @img_new,
          type: "image/png",
          url: "/xyz"
        }
      }
      | ip["images"]
    ]

    {:ok, %ProductSchema{} = product} = Product.add_images(product, %{"images" => images})
    image = product.images |> List.first()
    Product.update_default_image(product, to_string(image.id))
  end

  describe "product preloading" do
    setup do
      attrs = %{products: [build(:variant)]}
      product = insert(:product, attrs)
      [product: product]
    end

    test "with valid preload params" do
      preloads = [:products]
      product = Product.get_all_with_preloads(preloads) |> List.first()
      assert product.products != nil
    end

    test "with invalid preload params" do
      preloads = [:imag]
      products = Product.get_all_with_preloads(preloads)
      assert products == nil
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
      refute product_returned == nil
      assert product_returned.state == :deleted
    end

    test "fails product not found" do
      assert Product.delete(-1) == {:error, :product_not_found}
    end
  end

  describe "selling price" do
    test "for product" do
      product = insert(:product)
      product_selling_price = Product.get_selling_prices([product.id])

      assert %Money{} = Map.get(product_selling_price, product.id)
    end
  end

  describe "is_orderable?/1" do
    test "simple product and no product tracking" do
      product = insert(:product, inventory_tracking: :none)

      assert Product.is_orderable?(product)
    end

    test "product with variant and no product tracking" do
      attrs = %{products: [build(:variant)], inventory_tracking: :none}
      parent_product = insert(:product, attrs)
      variant = parent_product.products |> List.first()

      assert Product.is_orderable?(parent_product)
      assert Product.is_orderable?(variant)
    end

    test "simple product with inventory tracking by product" do
      product = insert(:product, inventory_tracking: :product)

      # Product has no stock
      refute Product.is_orderable?(product)

      stock_location = insert(:stock_location)

      stock_item =
        insert(:stock_item,
          count_on_hand: 10,
          product: product,
          stock_location: stock_location
        )

      # product has stock
      assert Product.is_orderable?(product)
    end

    test "product with variants and inventory tracking by product" do
      attrs = %{products: [build(:variant)], inventory_tracking: :product}
      parent_product = insert(:product, attrs)
      variant = parent_product.products |> List.first()

      refute Product.is_orderable?(parent_product)

      stock_location = insert(:stock_location)

      stock_item =
        insert(:stock_item,
          count_on_hand: 10,
          product: parent_product,
          stock_location: stock_location
        )

      # product has stock
      assert Product.is_orderable?(parent_product)

      # variant product will also be orderable as inventory is tracked by parent
      # product
      assert Product.is_orderable?(variant)
    end

    test "product with variants and inventory tracking by variant" do
      attrs = %{products: [build(:variant)], inventory_tracking: :variant}
      parent_product = insert(:product, attrs)
      variant = parent_product.products |> List.first()

      refute Product.is_orderable?(parent_product)

      # variant product does not have stock
      refute Product.is_orderable?(variant)

      stock_location = insert(:stock_location)

      stock_item =
        insert(:stock_item,
          count_on_hand: 10,
          product: variant,
          stock_location: stock_location
        )

      refute Product.is_orderable?(parent_product)

      assert Product.is_orderable?(variant)
    end
  end

  describe "product" do
    test "count by state" do
      taxon = insert(:taxon)
      product = insert(:product)
      {:ok, updated_product} = Product.update(product, %{state: :active, taxon_id: taxon.id})

      product_state_count = Product.get_product_count_by_state() |> List.first()

      assert product_state_count.count == 2
      assert product_state_count.state == :active
    end
  end

  describe "get_products_by_category/1" do
    test "get product from different category levels" do
      create_taxonomy()

      casual_shirt = TaxonomyDomain.get_taxon_by_name("Casual Shirt")
      insert_list(3, :product, taxon: casual_shirt, state: "active")

      assert Product.get_products_by_category(casual_shirt.id) |> length == 3

      formal_shirt = TaxonomyDomain.get_taxon_by_name("Formal Shirt")
      insert_list(5, :product, taxon: formal_shirt, state: "draft")

      assert Product.get_products_by_category(formal_shirt.id) |> length == 5

      shrug = TaxonomyDomain.get_taxon_by_name("Shrugs")
      assert Product.get_products_by_category(shrug.id) |> length == 0

      top_wear = TaxonomyDomain.get_taxon_by_name("TopWear")
      assert Product.get_products_by_category(top_wear.id) |> length == 8
    end
  end

  describe "delete_by_category/1" do
    test "delete product category" do
      create_taxonomy()

      casual_shirt = TaxonomyDomain.get_taxon_by_name("Casual Shirt")
      products = insert_list(3, :product, taxon: casual_shirt, state: "active")
      products_ids = Enum.map(products, & &1.id)

      {:ok, _} = Product.delete_by_category(casual_shirt)

      products_by_category = Product.get_products_by_category(casual_shirt.id)
      deleted_products = products_ids |> Enum.map(&get_product(Product.get(&1)))

      assert length(products_by_category) == 0

      deleted_products
      |> Enum.map(fn product ->
        assert product.state == :deleted
        assert product.taxon_id == nil
      end)
    end
  end

  defp get_product({:ok, product}) do
    product
  end

  describe "has_variants?/1" do
    test "product variant exist" do
      attrs = %{products: [build(:variant)]}
      product = insert(:product, attrs)

      assert Product.has_variants?(product)
    end

    test "product variant does not exist" do
      product = insert(:product)

      refute Product.has_variants?(product)
    end
  end

  describe "is_variant_tracking_enabled?/1" do
    test "inventory tracking is enabled" do
      product = insert(:product, inventory_tracking: :variant)

      assert Product.is_variant_tracking_enabled?(product)
    end

    test "inventory tracking is not enabled" do
      product = insert(:product, inventory_tracking: :product)

      refute Product.is_variant_tracking_enabled?(product)

      product = insert(:product, inventory_tracking: :none)

      refute Product.is_variant_tracking_enabled?(product)
    end
  end

  describe "get_parent_product/1" do
    setup do
      attrs = %{products: [build(:variant)]}
      product = insert(:product, attrs)
      [product: product, variants: product.products]
    end

    test "returns parent if variant supplied", context do
      %{product: product, variants: variants} = context
      variant = List.first(variants)
      parent = Product.get_parent_product(variant)
      assert parent.id == product.id
    end

    test "returns nil if parent product supplied", context do
      %{product: product} = context
      parent = Product.get_parent_product(product)
      refute parent
    end
  end

  describe "get_tax_class_id" do
    setup do
      attrs = %{products: [build(:variant)]}
      product = insert(:product, attrs)
      [product: product, variants: product.products]
    end

    test "returns parents tax class id if, variant supplied", context do
      %{product: product, variants: variants} = context
      variant = List.first(variants)
      refute variant.tax_class_id
      tax_class_id = Product.get_tax_class_id(variant)
      assert tax_class_id == product.tax_class_id
    end

    test "returns tax class id if, product supplied", context do
      %{product: product} = context
      tax_class_id = Product.get_tax_class_id(product)
      assert tax_class_id == product.tax_class_id
    end
  end

  defp get_naive_date_time(date) do
    Date.from_iso8601(date)
    |> elem(1)
    |> NaiveDateTime.new(~T[00:00:00])
    |> elem(1)
  end

  defp create_taxonomy() do
    Taxonomy.create_taxonomy({
      "Category",
      [
        {"Men",
         [
           {"TopWear",
            [
              {"TShirt", []},
              {"Casual Shirt", []},
              {"Formal Shirt", []}
            ]},
           {"BottomWear",
            [
              {"Jeans", []},
              {"Shorts", []}
            ]}
         ]},
        {"Women",
         [
           {"Western Wear",
            [
              {"Dresses & JumpSuit", []},
              {"Tops, Tshirts & Shirts", []},
              {"Shrugs", []}
            ]},
           {"Indian & Fusion Wear",
            [
              {"Kurta's & Suits", []},
              {"Skirts and Palazzos", []},
              {"Jackets and WaistCoats", []}
            ]}
         ]}
      ]
    })
  end
end
