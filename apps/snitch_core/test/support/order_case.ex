defmodule Snitch.OrderCase do
  @moduledoc """
  Test helpers to insert stock items and locations.
  """

  import Snitch.Factory

  @line_item %{
    quantity: nil,
    unit_price: nil,
    total: nil,
    variant_id: nil,
    order_id: nil,
    inserted_at: Ecto.DateTime.utc(),
    updated_at: Ecto.DateTime.utc()
  }

  @variant %{
    sku: nil,
    weight: Decimal.new("0.45"),
    height: Decimal.new("0.15"),
    depth: Decimal.new("0.1"),
    width: Decimal.new("0.4"),
    cost_price: Money.new("9.99", :USD),
    selling_price: random_price(:USD, 14, 4),
    shipping_category_id: nil,
    inserted_at: Ecto.DateTime.utc(),
    updated_at: Ecto.DateTime.utc()
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
      %{@variant | sku: "shoes-nike-#{index}", shipping_category_id: sc.id}
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
          variant_id: v.id,
          order_id: order_id,
          unit_price: v.selling_price,
          total: Money.mult!(v.selling_price, q)
      }
    end)
  end
end
