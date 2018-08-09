defmodule AdminAppWeb.ProductView do
  use AdminAppWeb, :view

  @currencies ["USD", "INR"]

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

  def get_brand_options(brands) do
    Enum.map(brands, fn brand -> {brand.name, brand.id} end)
  end

  def get_amount(nil) do
    "0"
  end

  def get_amount(money) do
    money.amount
    |> Decimal.to_string(:normal)
    |> Decimal.round(2)
  end

  # TODO This needs to fetched from config
  def get_currency() do
    @currencies
  end
end
