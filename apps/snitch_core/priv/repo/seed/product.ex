defmodule Snitch.Seed.Product do
  @moduledoc """
  Seeds Products with variants and their images.
  """
  alias Ecto.DateTime
  alias Snitch.Core.Tools.MultiTenancy.Repo

  alias Snitch.Data.Schema.{
    Image,
    Product,
    ShippingCategory,
    StockItem,
    StockLocation,
    Variant,
    Taxon
  }

  @base_path Application.app_dir(:snitch_core, "priv/seed_data/pets_shop")

  def seed do
    product_path = Path.join(@base_path, "products.json")

    with {:ok, file} <- File.read(product_path),
         {:ok, products_json} <- Jason.decode(file) do
      product_list = Enum.map(products_json["products"], &product/1)

      {_, products} = Repo.insert_all(Product, product_list, returning: [:id])

      light = Repo.get_by(ShippingCategory, name: "light")

      variants =
        products_json["products"]
        |> Enum.zip(products)
        |> Enum.map(fn {product_json, product} ->
          Enum.map(product_json["variants"], fn v -> variant(v, product.id, light.id) end)
        end)
        |> List.flatten()

      {_, variants} = Repo.insert_all(Variant, variants, returning: [:id])

      # Removed images section to be handled separately.
      # variant_images =
      #   products_json["products"]
      #   |> Enum.flat_map(fn products_json -> products_json["variants"] end)
      #   |> Enum.zip(variants)
      #   |> Enum.map(fn {variant_json, variant} ->
      #     Enum.map(variant_json["images"], fn url -> variant_image(url, variant.id) end)
      #   end)
      #   |> List.flatten()

      # filtered_images = Enum.map(variant_images, &Map.drop(&1, [:variant_id]))

      # {_, images} = Repo.insert_all(Image, filtered_images, returning: [:id])

      # variant_image_middle_entries =
      #   variant_images
      #   |> Enum.zip(images)
      #   |> Enum.map(fn {variant_image, image} ->
      #     %{variant_id: variant_image.variant_id, image_id: image.id}
      #   end)

      # Snitch.Core.Tools.MultiTenancy.Repo.insert_all(
      #   "snitch_variant_images",
      #   variant_image_middle_entries,
      #   returning: [:id]
      # )

      stock_location = Repo.all(StockLocation)

      stock_items =
        stock_location
        |> Enum.map(fn location ->
          Enum.map(variants, fn variant ->
            %{
              product_id: variant.id,
              stock_location_id: location.id,
              count_on_hand: 10,
              backorderable: true,
              inserted_at: Ecto.DateTime.utc(),
              updated_at: Ecto.DateTime.utc()
            }
          end)
        end)
        |> List.flatten()

      Repo.insert_all(StockItem, stock_items, returning: [:id])
    end
  end

  def variant_image(url, variant_id) do
    %{
      inserted_at: Ecto.DateTime.utc(),
      updated_at: Ecto.DateTime.utc(),
      variant_id: variant_id
    }
  end

  defp product(p) do
    taxon = Repo.get_by(Taxon, name: "Dry Food")

    %{
      name: p["name"],
      description: p["description"],
      slug: Slugger.slugify(p["name"]),
      available_on: DateTime.utc(),
      inserted_at: DateTime.utc(),
      updated_at: DateTime.utc(),
      selling_price: Money.new("14.99", :USD),
      max_retail_price: Money.new("12.99", :USD),
      taxon_id: taxon.id
    }
  end

  def variant(v, product_id, category_id) do
    %{
      sku: v["sku"],
      weight: v["weight"],
      height: v["height"],
      depth: v["depth"],
      selling_price: Money.from_float(v["selling_price"], String.to_atom(v["currency"])),
      cost_price: Money.from_float(v["cost_price"], String.to_atom(v["currency"])),
      position: 0,
      product_id: product_id,
      shipping_category_id: category_id,
      inserted_at: DateTime.utc(),
      updated_at: DateTime.utc()
    }
  end
end
