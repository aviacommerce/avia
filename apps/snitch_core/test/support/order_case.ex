defmodule Snitch.OrderCase do
  @moduledoc """
  Test helpers to insert stock items and locations.
  """

  @line_item %{
    quantity: nil,
    unit_price: nil,
    total: nil,
    variant_id: nil,
    order_id: nil,
    inserted_at: Ecto.DateTime.utc(),
    updated_at: Ecto.DateTime.utc()
  }

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
