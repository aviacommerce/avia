defmodule Snitch.Tools.Helper.Order do
  @moduledoc """
  Helpers to insert variants and line items for handcrafted orders.
  """

  @line_item %{
    quantity: nil,
    unit_price: nil,
    product_id: nil,
    order_id: nil,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  }

  @variant %{
    sku: nil,
    weight: Decimal.new("0.45"),
    height: Decimal.new("0.15"),
    depth: Decimal.new("0.1"),
    width: Decimal.new("0.4"),
    selling_price: nil,
    shipping_category_id: nil,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now(),
    slug: "",
    max_retail_price: nil
  }

  @doc """
  Returns a list of variant `map`s using the `manifest`.

  ## Manifest schema
  ```
  [
    %{category: %ShippingCategory{}}
  ]
  ```

  This result is suitable for a `Ecto.Repo.insert_all/3`
  """
  @spec variants_with_manifest([map], map) :: [map]
  def variants_with_manifest(manifest, context) do
    variant_count = Map.get(context, :variant_count, 3)

    manifest
    |> Stream.with_index()
    |> Stream.map(fn {%{category: sc}, index} ->
      %{
        @variant
        | sku: "shoes-nike-#{index}",
          shipping_category_id: sc.id,
          selling_price: random_price(:USD, 14, 4),
          slug: "product_slug-#{index}",
          max_retail_price: random_price(:USD, 14, 4)
      }
    end)
    |> Enum.take(variant_count)
  end

  @doc """
  Returns a list of line_item `map`s after zipping `variants` and
  `quanities`.

  The price fields are not computed. This result is suitable for a
  `Ecto.Repo.insert_all/3`
  """
  @spec line_items([Variant.t()], [integer], non_neg_integer | nil) :: [map]
  def line_items(variants, quantities, order_id \\ nil) do
    variants
    |> Stream.zip(quantities)
    |> Stream.reject(fn {_, q} -> q == 0 end)
    |> Enum.map(fn
      {v, q} when is_map(v) ->
        %{@line_item | quantity: q, variant_id: v.id, order_id: order_id}

      {v, q} when is_integer(v) ->
        %{@line_item | quantity: q, variant_id: v, order_id: order_id}
    end)
  end

  @doc """
  Returns a list of line_item `map`s after zipping `variants` and
  `quanities` with price fields.

  The price fields are not computed. This result is suitable for a
  `Ecto.Repo.insert_all/3`
  """
  @spec line_items_with_price([Variant.t()], [integer], non_neg_integer | nil) :: [map]
  def line_items_with_price(variants, quantities, order_id \\ nil) do
    variants
    |> Stream.zip(quantities)
    |> Stream.reject(fn {_, q} -> q == 0 end)
    |> Enum.map(fn {v, q} when is_map(v) ->
      %{
        @line_item
        | quantity: q,
          product_id: v.id,
          order_id: order_id,
          unit_price: v.selling_price
      }
    end)
  end

  defp random_price(currency, min, delta) do
    Money.new(currency, "#{:rand.uniform(delta) + min}.99")
  end
end
