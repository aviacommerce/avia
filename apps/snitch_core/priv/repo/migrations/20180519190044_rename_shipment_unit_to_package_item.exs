defmodule Snitch.Repo.Migrations.RenameShipmentUnitToPackageItem do
  use Ecto.Migration

  def change do
    drop table("snitch_shipment_units")

    create table("snitch_package_items") do
      add :number, :string, null: false, comment: "A human readable unique identifier"
      add :state, :string, null: false
      add :quantity, :integer, null: false
      add :delta, :integer, comment: "The fulfillment deficit (if any)"
      add :backordered?, :boolean, null: false
      add :line_item_id, references("snitch_line_items", on_delete: :nothing)
      add :variant_id, references("snitch_variants", on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index("snitch_package_items", [:number])
  end
end
