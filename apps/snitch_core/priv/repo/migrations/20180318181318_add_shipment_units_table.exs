defmodule Snitch.Repo.Migrations.AddShipmentUnitsTable do
  use Ecto.Migration

  def change do
    create table("snitch_shipment_units") do
      add(:state, :string)
      add(:quantity, :integer)

      add(:variant_id, references(:snitch_variants))
      add(:line_item_id, references(:snitch_line_items))
      # add(:shipment_id, references(:snitch_shipments))

      timestamps()
    end

    create index(:snitch_shipment_units, [:line_item_id])
    #create index(:snitch_shipment_units, [:shipment_id])
    create index(:snitch_shipment_units, [:variant_id])
  end
end
