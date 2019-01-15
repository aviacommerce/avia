defmodule Snitch.Repo.Migrations.AddUpnFieldToProducts do
  use Ecto.Migration

  def change do
    alter table("snitch_products") do
      add(:upn, :string)
    end

    create unique_index("snitch_products", [:upn])
  end
end
