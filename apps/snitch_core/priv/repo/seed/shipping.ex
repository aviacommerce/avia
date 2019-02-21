defmodule Snitch.Seed.Shipping do
  @moduledoc false

  import Ecto.Query
  import Snitch.Tools.Helper.{Shipment, Zone}

  alias Snitch.Data.Model.{Country, ShippingMethod, State}
  alias Snitch.Data.Schema.State, as: StateSchema
  alias Snitch.Data.Schema.ShippingMethod, as: ShippingMethodSchema
  alias Snitch.Data.Schema.{ShippingCategory, Zone}
  alias Snitch.Core.Tools.MultiTenancy.Repo

  @shipping_categories ~w(light)

  @zone_manifest %{
    "apac" => %{zone_type: "C"},
    "india" => %{zone_type: "S", is_default: true},
    "north-india" => %{zone_type: "S"}
  }

  def seed! do
    [light] = seed_shipping_categories!()
    all_zones = [apac, india, north_india] = seed_zones!()

    manifest = %{
      "smuggle" => {[apac], [light]},
      "priority" => {all_zones, [light]},
      "regular" => {[india, north_india], [light]},
      "hyperloop" => {[north_india], [light]}
    }

    Enum.map(manifest, fn {name, {zones, categories}} ->
      ShippingMethod.create(%{name: name, slug: name}, zones, categories)
    end)
  end

  def seed_shipping_categories! do
    shipping_categories_with_manifest(@shipping_categories)
    Repo.all(ShippingCategory)
  end

  defp get_state(code_params) do
    {:ok, state} = State.get(code_params)
    state
  end

  def seed_zones! do
    Repo.delete_all(Zone)
    Repo.delete_all(ShippingMethodSchema)
    all_zones = [apac, india, north_india] = zones_with_manifest(@zone_manifest)

    {:ok, ind} = Country.get(%{iso: "IN"})
    {:ok, ch} = Country.get(%{iso: "CH"})
    {:ok, jp} = Country.get(%{iso: "JP"})

    states = Repo.all(from(s in StateSchema, where: s.country_id == ^ind.id))

    northern = [
      get_state(%{code: "IN-UP"}),
      get_state(%{code: "IN-BR"}),
      get_state(%{code: "IN-CH"}),
      get_state(%{code: "IN-CT"}),
      get_state(%{code: "IN-DL"}),
      get_state(%{code: "IN-RJ"}),
      get_state(%{code: "IN-UT"}),
      get_state(%{code: "IN-PB"})
    ]

    zone_members([
      {apac, [ind, ch, jp]},
      {india, states},
      {north_india, northern}
    ])

    all_zones
  end
end
