defmodule Snitch.Repo.Migrations.AddTaxClassAndConfigTable do
  use Ecto.Migration

  def change do
    create table(:snitch_tax_classes) do
      add(:name, :string, null: false)
      add(:is_default, :boolean, default: false)

      timestamps()
    end

    create unique_index(:snitch_tax_classes, [:name])
    create unique_index(:snitch_tax_classes, [:is_default], where: "is_default=true",
    name: :unique_default_tax_class)

    create table(:snitch_tax_configuration) do
      add(:label, :string)
      add(:included_in_price?, :boolean, default: true)
      add(:calculation_address_type, AddressTypes.type())
      add(:preferences, :map)

      add(:shipping_tax_id, references(:snitch_tax_classes, on_delete: :restrict))
      add(:gift_tax_id, references(:snitch_tax_classes, on_delete: :restrict))
      add(:default_country_id, references(:snitch_countries, on_delete: :restrict))
      add(:default_state_id, references(:snitch_states, on_delete: :restrict))

      timestamps()
    end
  end
end
