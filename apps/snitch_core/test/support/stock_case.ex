defmodule Snitch.StockCase do
  @moduledoc """
  Test helpers to insert stock items and locations.

  ## Sample manifests
  ```
  stock_item_sample_manifest = %{
    "default" => [
      %{count_on_hand: 3, backorderable: true},
      %{count_on_hand: 3, backorderable: true},
      %{count_on_hand: 3, backorderable: true}
    ],
    "backup" => [
      %{count_on_hand: 0},
      %{count_on_hand: 0},
      %{count_on_hand: 6}
    ],
    "origin" => [ # this is the `admin_name` of the `stock_location`
      %{count_on_hand: 3},
      %{count_on_hand: 3},
      %{count_on_hand: 3}
    ]
  }
  """

  @stock_item %{
    backorderable: false,
    count_on_hand: nil,
    variant_id: nil,
    stock_location_id: nil,
    inserted_at: Ecto.DateTime.utc(),
    updated_at: Ecto.DateTime.utc()
  }

  @stock_location %{
    name: nil,
    admin_name: nil,
    address_line_1: "",
    state_id: nil,
    country_id: nil,
    backorderable_default: false,
    propagate_all_variants: false,
    default: false,
    active: true,
    inserted_at: Ecto.DateTime.utc(),
    updated_at: Ecto.DateTime.utc()
  }

  def stock_locations_with_manifest(manifest) do
    Enum.map(manifest, fn {name, params} ->
      %{Map.merge(@stock_location, params) | admin_name: name}
    end)
  end

  def stock_items_with_manifest(manifest, variants, locations) do
    manifest
    |> Enum.map(fn {name, param_list} ->
      variants
      |> Stream.zip(param_list)
      |> Enum.map(fn {v, params} when is_map(v) and is_map(params) ->
        %{
          Map.merge(@stock_item, params)
          | variant_id: v.id,
            stock_location_id: locations[name].id
        }
      end)
    end)
    |> List.flatten()
  end
end
