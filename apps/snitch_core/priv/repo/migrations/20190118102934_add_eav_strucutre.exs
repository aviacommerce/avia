defmodule Snitch.Repo.Migrations.Add_EAVStrucutre do
  use Ecto.Migration

  def change do
    create table(:snitch_entities) do
      add(:name, :string, null: false)
      add(:identifier, EntityIdentifier.type())
      add(:description, :string)

      timestamps()
    end

    create table(:snitch_attributes) do
      add(:name, :string, null: false)
      add(:description, :string)
      add(:entity_id, references(:snitch_entities, on_delete: :restrict), null: false)

      timestamps()
    end

    create unique_index(:snitch_attributes, [:name, :entity_id],
      name: :unique_attribute_per_entity)

    create table(:snitch_attributes_metadata) do
      add(:data_type, AttributeDataType.type())
      add(:presentation, :string)
      add(:is_required, :boolean)
      add(:belongs_to_type, AttributeRelations.type())
      add(:attribute_id, references(:snitch_attributes, on_delete: :delete_all),
        null: false)
    end

    create table(:snitch_eav_type_boolean) do
      add(:value, :boolean, null: false)
      add(:attribute_id, references(:snitch_attributes, on_delete: :restrict), null: false)
      timestamps()
    end

    create table(:snitch_eav_type_datetime) do
      add(:value, :utc_datetime, null: false)
      add(:attribute_id, references(:snitch_attributes, on_delete: :restrict), null: false)
      timestamps()
    end

    create table(:snitch_eav_type_decimal) do
      add(:value, :decimal, null: false)
      add(:attribute_id, references(:snitch_attributes, on_delete: :restrict), null: false)
      timestamps()
    end

    create table(:snitch_eav_type_integer) do
      add(:value, :integer, null: false)
      add(:attribute_id, references(:snitch_attributes, on_delete: :restrict), null: false)
      timestamps()
    end

    create table(:snitch_eav_type_string) do
      add(:value, :string, null: false)
      add(:attribute_id, references(:snitch_attributes, on_delete: :restrict), null: false)
      timestamps()
    end
  end
end
