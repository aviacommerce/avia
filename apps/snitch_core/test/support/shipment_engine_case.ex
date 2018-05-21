defmodule Snitch.ShipmentEngineCase do
  @moduledoc """
  Test helper for creating packages for shipment engine.

  Creates packages based on the type of package for given lineitems.
  > A package of type [1,0,1,0] means the package will fulfill 
    first and third lineitem.
  """
  alias Snitch.Data.Schema.LineItem

  @package %{
    items: [
      %{
        variant: nil,
        line_item: nil,
        variant_id: 0,
        state: nil,
        quantity: 0,
        delta: 0
      }
    ],
    backorders?: true,
    variants: MapSet.new()
  }

  @doc """
  Returns pacakges with varied degree of fulfillment
  for given `listitems`.
  """
  @spec packages([%LineItem{}], map, list) :: term
  def packages(lineitems, %{variants: vs}, package_types) do
    for i <- package_types do
      package_with_items(lineitems, vs, i)
    end
  end

  defp package_with_items(lineitems, variants, item_fulfillment) do
    items =
      lineitems
      |> Stream.zip(variants)
      |> Stream.zip(item_fulfillment)
      |> Enum.map(fn {{li, v}, itf} ->
        if itf == 1 do
          %{
            variant: v,
            line_item: li,
            state: :fulfilled,
            quantity: li.quantity,
            delta: 0
          }
        end
      end)
      |> Enum.filter(fn x -> is_nil(x) == false end)

    variants =
      variants
      |> Stream.zip(item_fulfillment)
      |> Enum.reduce(MapSet.new(), fn
        {%{id: id}, 1}, acc -> MapSet.put(acc, id)
        {_, 0}, acc -> acc
      end)

    bo = Enum.any?(item_fulfillment, fn x -> x == 0 end)
    %{@package | items: items, backorders?: bo, variants: variants}
  end
end
