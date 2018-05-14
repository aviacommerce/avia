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

  setup :zones
  setup :shipping_categories

  @tag state_zone_count: 1, shipping_category_count: 1
  describe "create shipping_method" do
    test "changeset with valid params and zones", context do
      %{zones: zones, shipping_categories: categories} = context

      %{valid?: validity} =
        changeset =
        ShippingMethod.create_changeset(%ShippingMethod{}, @valid_params, zones, categories)

      assert validity
      assert Enum.all?(changeset.changes.zones, fn cset -> cset.action == :update end)

      assert Enum.all?(changeset.changes.shipping_categories, fn cset ->
               cset.action == :update
             end)

      assert {:ok, _} = Repo.insert(changeset)
    end

    test "changeset with valid params and no zones or categories" do
      %{valid?: validity} =
        ShippingMethod.create_changeset(%ShippingMethod{}, @valid_params, [], [])

      assert validity
    end

    test "name, slug, description cannot be blank", context do
      %{zones: zones, shipping_categories: categories} = context

      %{valid?: validity} =
        changeset = ShippingMethod.create_changeset(%ShippingMethod{}, %{}, zones, categories)

      refute validity

      assert %{
               name: ["can't be blank"],
               slug: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "fails with a duplicate slug", context do
      [shipping_method: sm] = shipping_method(context)

      cs =
        %{valid?: validity} =
        ShippingMethod.create_changeset(
          %ShippingMethod{},
          %{@valid_params | slug: sm.slug},
          [],
          []
        )

      assert validity
      assert {:error, cs} = Repo.insert(cs)
      assert %{slug: ["has already been taken"]} = errors_on(cs)
    end

    @tag state_zone_count: 1, country_zone_count: 1, shipping_category_count: 1
    test "allow zones of different types", context do
      %{zones: zones, shipping_categories: categories} = context

      %{valid?: validity} =
        ShippingMethod.create_changeset(%ShippingMethod{}, @valid_params, zones, categories)

      assert validity
    end
  end

  @tag country_zone_count: 3, shipping_category_count: 1
  describe "update shipping_method" do
    setup :shipping_method

    test "slugs must be unique" do
      cs = ShippingMethod.create_changeset(%ShippingMethod{}, @valid_params, [], [])
      assert {:error, changeset} = Repo.insert(cs)
      assert %{slug: ["has already been taken"]} = errors_on(changeset)
    end

    test "allow zones, categories to be replaced", %{shipping_method: sm} do
      [zones: new_zones] = zones(%{state_zone_count: 2})
      [shipping_categories: new_categories] = shipping_categories(%{shipping_category_count: 2})

      cs =
        %{valid?: validity} = ShippingMethod.update_changeset(sm, %{}, new_zones, new_categories)

      assert validity
      assert Enum.all?(cs.changes.zones, fn cset -> cset.action == :update end)
      assert {:ok, sm} = Repo.update(cs)
      assert length(sm.zones) == 2
      assert length(sm.shipping_categories) == 2
      assert Enum.all?(sm.zones, fn %{zone_type: type} -> type == "S" end)
    end

    test "allow zones, categories to be removed", %{shipping_method: sm} do
      cs = %{valid?: validity} = ShippingMethod.update_changeset(sm, %{}, [], [])
      assert validity
      assert {:ok, sm} = Repo.update(cs)
      assert [] = sm.zones
      assert [] = sm.shipping_categories
    end
  end

  defp shipping_method(%{zones: zones, shipping_categories: categories}) do
    {:ok, sm} =
      %ShippingMethod{}
      |> ShippingMethod.create_changeset(
        @valid_params,
        zones,
        categories
      )
      |> Repo.insert()

    [shipping_method: sm]
  end
end
