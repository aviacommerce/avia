defmodule Snitch.Repo.Migrations.AddDefaultToTaxZone do
  use Ecto.Migration

  def change do
    alter table("snitch_zones") do
      add(:is_default, :boolean, default: false)
    end

    create unique_index("snitch_zones", [:is_default], where: "is_default=true",
      name: :unique_default_zone)

    alter table("snitch_tax_zones") do
      add(:is_default, :boolean, default: false)
    end

    create unique_index("snitch_tax_zones", [:is_default], where: "is_default=true",
      name: :unique_default_tax_zone)
  end
end
