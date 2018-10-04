defmodule AdminAppWeb.ProductView do
  use AdminAppWeb, :view
  alias Snitch.Data.Model.Product
  alias Snitch.Data.Schema.{Variation, ShippingCategory}
  alias Snitch.Repo
  import Ecto.Query

  @currencies ["USD", "INR"]

  def get_image_url(images) do
    image = images |> List.first()
    image.url
  end

  def themes_options(product) do
    Enum.map(product.taxon.variation_themes, fn theme -> {theme.name, theme.id} end)
  end

  # TODO This needs to be replaced and we need a better system to identify
  # the type of product.
  def is_parent_product(product_id) when is_binary(product_id) do
    query =
      from(
        p in "snitch_product_variants",
        where: p.parent_product_id == ^(product_id |> String.to_integer()),
        select: fragment("count(*)")
      )

    count = Snitch.Repo.one(query)
    count > 0
  end

  def can_add_variant(product) do
    has_themes(product) && !is_child_product(product)
  end

  def has_themes(product) do
    length(product.taxon.variation_themes) > 0
  end

  defp is_child_product(product) do
    query = from(c in Variation, where: c.child_product_id == ^product.id)
    count = Repo.aggregate(query, :count, :id)
    count > 0
  end

  def has_variants(product) do
    product.variants |> length > 0
  end

  def get_option_types(product) do
    variant = product.variants |> List.first()

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

  def get_taxon(conn) do
    conn.params["taxon"]
  end

  def get_currency_value(nil) do
    @currencies |> List.first()
  end

  def get_currency_value(money) do
    money.currency
  end

  # TODO This needs to fetched from config
  def get_currency() do
    @currencies
  end

  def get_image_url(image, product) do
    Product.image_url(image.name, product)
  end

  def get_variant_option(variants) do
    Enum.map(variants, fn variant -> {variant.name, variant.id} end)
  end

  def get_stock_locations_option(locations) do
    Enum.map(locations, fn location -> {location.name, location.id} end)
  end

  def get_shipping_category() do
    ShippingCategory
    |> order_by([sc], asc: sc.name)
    |> Ecto.Query.select([sc], {sc.name, sc.id})
    |> Repo.all()
  end
end
