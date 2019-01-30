defmodule Snitch.Repo.Migrations.AddTaxZone do
  use Ecto.Migration

  def change do
    create table(:snitch_tax_zones) do
      add(:name, :string, nil: false)
      add(:is_active?, :boolean, default: true)
      add(:zone_id, references("snitch_zones", on_delete: :restrict), nil: false)

      timestamps()
    end

    create unique_index(:snitch_tax_zones, [:name])
    create unique_index(:snitch_tax_zones, [:zone_id], name: :unique_zone_for_tax)

    drop table(:snitch_tax_rates)

    create table(:snitch_tax_rates) do
      add(:name, :string, null: false)
      add(:priority, :integer, default: 0)
      add(:is_active?, :boolean, default: true)

      add(:tax_zone_id, references(:snitch_tax_zones, on_delete: :delete_all), null: false)

      timestamps()
    end

    create unique_index(:snitch_tax_rates, [:name, :tax_zone_id],
      name: :unique_tax_rate_name_for_tax_zone)

    create table(:snitch_tax_rate_class_values) do
      add(:percent_amount, :integer, null: false)
      add(:tax_rate_id, references(:snitch_tax_rates, on_delete: :delete_all), null: false)
      add(:tax_class_id, references(:snitch_tax_classes, on_delete: :delete_all), null: false)

      timestamps()
    end

    create unique_index(:snitch_tax_rate_class_values, [:tax_rate_id, :tax_class_id],
      name: :unique_tax_rate_class_value)
  end
end
