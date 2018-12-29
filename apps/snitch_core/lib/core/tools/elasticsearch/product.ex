defimpl Elasticsearch.Document, for: Snitch.Data.Schema.Product do
  alias Snitch.Data.Model.ProductReview, as: PRModel
  alias Snitch.Data.Model.Image, as: ImageModel

  def id(product), do: "#{product.tenant}_#{product.id}"
  def routing(_), do: false
  def type(_product), do: "product"

  def encode(product) do
    self_or_parent_product = parent_or_standalone_product(product)
    # Example => "Iphone 6s (Space Grey, 32GB, 2GB RAM)"
    product = append_option_value_in_name(product)

    %{
      name: product.name,
      suggest_keywords: suggest_keywords(product),
      slug: self_or_parent_product.slug,
      parent_id: self_or_parent_product.id,
      # description: product.description,
      selling_price: product.selling_price,
      max_retail_price: product.max_retail_price,
      rating_summary: avg_rating(self_or_parent_product),
      images: product_images(product),
      updated_at: product.updated_at,
      tenant: product.tenant,
      filters: generate_filter_fields(product, self_or_parent_product),
      discount: product_discount(product)
      # meta_keywords: product.meta_keywords,
    }
  end

  defp parent_or_standalone_product(%{parent_variation: nil} = product), do: product
  defp parent_or_standalone_product(product), do: product.parent_variation.parent_product

  defp append_option_value_in_name(%{options: []} = product), do: product

  defp append_option_value_in_name(%{options: options} = product) do
    postfix =
      options
      |> Enum.map(&String.capitalize(&1.value))
      |> Enum.join(",")

    %{product | name: product.name <> " (" <> postfix <> ")"}
  end

  defp generate_filter_fields(product, self_or_parent_product) do
    [
      gen_taxon_path(product.taxon)
      | Enum.map(product.options, &option_map/1) ++ brand_map(self_or_parent_product.brand)
    ]
  end

  defp gen_taxon_path(nil), do: []

  defp gen_taxon_path(taxon) do
    %{id: "Category", value: taxon.name}
    # taxon = Repo.preload(taxon, :parent)
    # gen_taxon_path(taxon.parent) ++ [%{id: taxon.id, name: taxon.name}]
  end

  defp option_map(option) do
    %{
      id: option.option_type.display_name,
      value: option.value
    }
  end

  defp brand_map(nil), do: []

  defp brand_map(brand) do
    [
      %{
        id: "Brand",
        value: brand.name
      }
    ]
  end

  # If stand alone product, then use its images
  defp product_images(%{parent_variation: nil, images: images} = product) do
    Enum.map(images, &image_map(product, &1))
  end

  # If variant does not have images, then use parent images
  defp product_images(
         %{
           parent_variation: %{parent_product: %{images: parent_images, id: parent_id}},
           images: []
         } = product
       ) do
    product_images(%{product | parent_variation: nil, images: parent_images, id: parent_id})
  end

  # If variant has images, then use those images
  defp product_images(%{images: images} = product) do
    product_images(%{product | parent_variation: nil, images: images})
  end

  defp image_map(product, image) do
    %{
      product_url: ImageModel.image_url(image.name, product)
    }
  end

  defp avg_rating(product) do
    %{
      average_rating: average_rating,
      review_count: review_count,
      rating_list: rating_list
    } = PRModel.review_aggregate(product)

    %{
      average_rating: average_rating |> Decimal.round(1) |> Decimal.to_float(),
      review_count: review_count,
      rating_list:
        Enum.map(rating_list, fn {k, %{value: v, position: p}} ->
          {k, %{value: v |> Decimal.round(1) |> Decimal.to_float(), position: p}}
        end)
        |> Enum.into(%{})
    }
  end

  defp suggest_keywords(%{name: name, meta_keywords: meta_keywords}) do
    keywords = String.split(name, ~r(\s+)) ++ String.split(meta_keywords || "", ~r(\s*\,\s*))
    Enum.filter(keywords, &("" != &1))
  end

  defp product_discount(product) do
    product.selling_price.amount
    |> Decimal.div(product.max_retail_price.amount)
    |> Decimal.mult(100)
    |> Decimal.round(0)
    |> Decimal.to_integer()
  end
end
