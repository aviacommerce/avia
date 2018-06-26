defmodule Snitch.Domain.ShippingMethodTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Tools.Helper.Zone, only: [zones_with_manifest: 1]
  import Snitch.Tools.Helper.Shipment

  alias Snitch.Domain.ShippingMethod

  @zone_manifest %{
    "intl" => %{zone_type: "C"},
    "domestic" => %{zone_type: "S"},
    "some_states" => %{zone_type: "S"}
  }

  setup do
    categories =
      [light, _heavy, fragile] = shipping_categories_with_manifest(~w(light heavy fragile))

    zones = [intl, domestic, some_states] = zones_with_manifest(@zone_manifest)

    manifest = %{
      "smuggle" => {[intl], [light]},
      "priority" => {zones, [light, fragile]},
      "regular" => {[domestic, some_states], categories},
      "hyperloop" => {[some_states], [light, fragile]}
    }

    methods =
      [_smuggle, _regular, _priority, _hyperloop] = shipping_methods_with_manifest(manifest)

    [
      shipping_categories: categories,
      zones: zones,
      shipping_methods: methods
    ]
  end

  test "various scenarios", context do
    %{
      shipping_categories: [light, heavy, fragile],
      zones: [intl, domestic, some_states]
    } = context

    assert MapSet.equal?(
             MapSet.new(),
             zone_names([intl], heavy)
           )

    assert MapSet.equal?(
             MapSet.new(~w(smuggle priority)),
             zone_names([intl], light)
           )

    assert MapSet.equal?(
             MapSet.new(~w(regular priority)),
             zone_names([domestic], fragile)
           )

    assert MapSet.equal?(
             MapSet.new(~w(regular)),
             zone_names([domestic, some_states], heavy)
           )

    assert MapSet.equal?(
             MapSet.new(~w(regular priority hyperloop)),
             zone_names([domestic, some_states], light)
           )

    assert MapSet.equal?(
             MapSet.new(),
             zone_names([], light)
           )

    assert_raise FunctionClauseError, fn ->
      zone_names([domestic, some_states], nil)
    end

    assert_raise FunctionClauseError, fn ->
      zone_names(nil, light)
    end
  end

  defp zone_names(zones, category) do
    zones
    |> ShippingMethod.for_package(category)
    |> Enum.map(fn %{name: name} -> name end)
    |> MapSet.new()
  end
end
