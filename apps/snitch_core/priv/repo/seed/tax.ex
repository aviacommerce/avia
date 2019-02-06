defmodule Snitch.Seed.Tax do
  @moduledoc """
  Seeds basic setup required for taxation.

  ##Note
  Country and states to be seeded first.
  """
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Schema.{TaxClass, TaxConfig, Zone, TaxZone}
  alias Snitch.Data.Model.TaxClass, as: TaxClassModel
  alias Snitch.Data.Model.Country

  @tax_class_manifest [
    %{name: "Default Tax Class", is_default: true},
    %{name: "Shipping Tax", is_default: false},
    %{name: "Gift Tax", is_default: false},
    %{name: "Product Tax", is_default: false}
  ]

  @tax_class %{
    name: "",
    is_default: false,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  }

  @default_tax_zone_params %{
    name: "Default Tax Zone",
    is_active?: true,
    zone_id: nil,
    is_default: true
  }

  def seed() do
    seed_tax_classes()
    seed_tax_config()
    seed_default_tax_zone!()
  end

  def seed_tax_classes() do
    tax_classes =
      Enum.map(@tax_class_manifest, fn class ->
        %{@tax_class | name: class.name, is_default: class.is_default}
      end)

    Repo.insert_all(TaxClass, tax_classes,
      on_conflict: :nothing,
      returning: false
    )
  end

  def seed_tax_config() do
    {:ok, tax_class} = TaxClassModel.get(%{name: "Default Tax Class"})
    {:ok, country} = Country.get(%{iso3: "USA"})

    tax_config_params = %{
      label: "Sales Tax",
      shipping_tax_id: tax_class.id,
      gift_tax_id: tax_class.id,
      default_country_id: country.id
    }

    changeset = TaxConfig.create_changeset(%TaxConfig{}, tax_config_params)

    Repo.delete_all(TaxConfig)
    Repo.insert(changeset, returning: false)
  end

  def seed_default_tax_zone!() do
    default_zone = Repo.get_by!(Zone, is_default: true)
    params = %{@default_tax_zone_params | zone_id: default_zone.id}
    changeset = TaxZone.create_changeset(%TaxZone{}, params)

    Repo.insert(changeset, on_conflict: :nothing)
  end
end
