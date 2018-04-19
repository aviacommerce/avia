defmodule Snitch.Data.Schema.ShippingMethodTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.ShippingMethod

  @valid_params %{
    slug: "shipping-method-0",
    name: "FREE One Day delivery",
    description: "*Conditions apply :)"
  }

  @tag state_zone_count: 3
  describe "create shipping_method" do
    setup :zones

    test "changeset with valid params and zones", %{zones: zones} do
      %{valid?: validity} =
        changeset = ShippingMethod.create_changeset(%ShippingMethod{}, @valid_params, zones)

      assert validity
      assert Enum.all?(changeset.changes.zones, fn cset -> cset.action == :update end)
    end

    test "changeset with valid params and no zones" do
      %{valid?: validity} = ShippingMethod.create_changeset(%ShippingMethod{}, @valid_params, [])

      assert validity
    end

    test "name, slug, description cannot be blank", %{zones: zones} do
      %{valid?: validity} =
        changeset = ShippingMethod.create_changeset(%ShippingMethod{}, %{}, zones)

      refute validity

      assert %{
               description: ["can't be blank"],
               name: ["can't be blank"],
               slug: ["can't be blank"]
             } = errors_on(changeset)
    end

    @tag state_zone_count: 1, country_zone_count: 1
    test "allow zones of different types", %{zones: zones} do
      %{valid?: validity} =
        ShippingMethod.create_changeset(%ShippingMethod{}, @valid_params, zones)

      assert validity
    end
  end

  @tag country_zone_count: 3
  describe "update shipping_method" do
    setup :zones
    setup :shipping_method

    test "slugs must be unique" do
      cs = ShippingMethod.create_changeset(%ShippingMethod{}, @valid_params, [])
      assert {:error, changeset} = Repo.insert(cs)
      assert %{slug: ["has already been taken"]} = errors_on(changeset)
    end

    test "allow zones to be replaced", %{shipping_method: sm} do
      [zones: new_zones] = zones(%{country_zone_count: 2})

      cs = %{valid?: validity} = ShippingMethod.update_changeset(sm, %{}, new_zones)
      assert validity
      assert Enum.all?(cs.changes.zones, fn cset -> cset.action == :update end)
      assert {:ok, _} = Repo.update(cs)
    end

    test "allow zones to be removed", %{shipping_method: sm} do
      cs = %{valid?: validity} = ShippingMethod.update_changeset(sm, %{}, [])
      assert validity
      assert {:ok, _} = Repo.update(cs)
    end
  end

  defp shipping_method(%{zones: zones}) do
    cs = ShippingMethod.create_changeset(%ShippingMethod{}, @valid_params, zones)
    {:ok, sm} = Repo.insert(cs)
    [shipping_method: sm]
  end
end
