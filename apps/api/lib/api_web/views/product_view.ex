defmodule ApiWeb.ProductView do
  use ApiWeb, :view

  def render("products.json", %{products: products}) do
    %{products: render_many(products, __MODULE__, "product.json")}
  end

  def render("product.json", %{product: product}) do
    variant = product.variants |> List.first()
    {:ok, display_price} = variant.selling_price |> Money.to_string(locale: "en")

    %{
      id: product.id,
      name: product.name,
      description: product.description,
      price: variant.selling_price.amount,
      display_price: display_price,
      available_on: "2018-05-01T00:00:00.000Z",
      slug: product.slug,
      meta_description: "",
      meta_keywords: "",
      shipping_category_id: 1,
      total_on_hand: 11,
      master: %{
        id: variant.id,
        name: product.name,
        sku: variant.sku,
        price: variant.selling_price.amount,
        weight: variant.weight,
        height: variant.height,
        width: variant.width,
        depth: variant.depth,
        is_master: true,
        slug: product.slug,
        description: product.description,
        track_inventory: true,
        cost_price: nil,
        option_values: [],
        images: Enum.map(variant.images, &image_variant/1),
        display_price: display_price,
        options_text: "",
        in_stock: true,
        is_backorderable: true,
        is_orderable: true,
        total_on_hand: 11,
        is_destroyed: false
      },
      variants: [],
      option_types: [],
      product_properties: [],
      has_variants: false,
      is_favorited_by_current_user: false
    }
  end

  def image_variant(image) do
    %{
      id: image.id,
      position: 1,
      attachment_content_type: "image/png",
      attachment_file_name: "cat.jpg",
      attachment_width: 299,
      attachment_height: 370,
      alt: "Image",
      viewable_id: 71,
      mini_url: image.url,
      small_url: image.url,
      product_url: image.url,
      large_url: image.url
    }
  end
end
