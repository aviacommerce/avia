defmodule Snitch.Seed.Shipping do
  @moduledoc false

  import Ecto.Query
  import Snitch.Tools.Helper.{Shipment, Zone}

  alias Snitch.Data.Model.{Country, ShippingMethod, State}
  alias Snitch.Data.Schema.State, as: StateSchema
  alias Snitch.Data.Schema.ShippingMethod, as: ShippingMethodSchema
  alias Snitch.Data.Schema.{ShippingCategory, Zone}
  alias Snitch.Core.Tools.MultiTenancy.Repo

  @shipping_categories ~w(light heavy fragile)

  @zone_manifest %{
    "apac" => %{zone_type: "C"},
    "india" => %{zone_type: "S"},
    "north-india" => %{zone_type: "S"}
  }

  def seed! do
    all_categories = [light, _heavy, fragile] = seed_shipping_categories!()
    all_zones = [apac, india, north_india] = seed_zones!()

    manifest = %{
      "smuggle" => {[apac], [light]},
      "priority" => {all_zones, [light, fragile]},
      "regular" => {[india, north_india], all_categories},
      "hyperloop" => {[north_india], [light, fragile]}
    }

    Enum.map(manifest, fn {name, {zones, categories}} ->
      ShippingMethod.create(%{name: name, slug: name}, zones, categories)
    end)
  end

  def seed_shipping_categories! do
    shipping_categories_with_manifest(@shipping_categories)
    Repo.all(ShippingCategory)
  end

  def seed_zones! do
    Repo.delete_all(Zone)
    Repo.delete_all(ShippingMethodSchema)
    all_zones = [apac, india, north_india] = zones_with_manifest(@zone_manifest)

    ind = Country.get(%{iso: "IN"})
    ch = Country.get(%{iso: "CH"})
    jp = Country.get(%{iso: "JP"})

    states = Repo.all(from(s in StateSchema, where: s.country_id == ^ind.id))

    northern = [
      State.get(%{code: "IN-UP"}),
      State.get(%{code: "IN-BR"}),
      State.get(%{code: "IN-CH"}),
      State.get(%{code: "IN-CT"}),
      State.get(%{code: "IN-DL"}),
      State.get(%{code: "IN-RJ"}),
      State.get(%{code: "IN-UT"}),
      State.get(%{code: "IN-PB"})
    ]

    zone_members([
      {apac, [ind, ch, jp]},
      {india, states},
      {north_india, northern}
    ])

    all_zones
  end
end
