defmodule AdminAppWeb.ProductView do
  use AdminAppWeb, :view

  def get_image_url(images) do
    image = images |> List.first()
    image.url
  end

  def themes_options(themes) do
    Enum.map(themes, fn theme -> {theme.name, theme.id} end)
  end

  def has_variants(parent_product) do
    parent_product.variants |> length > 0
  end

  def get_option_types(parent_product) do
    variant = parent_product.variants |> List.first()

    variant.options
    |> Enum.map(fn x -> x.option_type end)
  end
end
