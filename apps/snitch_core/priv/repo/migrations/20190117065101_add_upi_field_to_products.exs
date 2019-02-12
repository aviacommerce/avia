defmodule Snitch.Repo.Migrations.AddUpiFieldToProducts do
  use Ecto.Migration

  def change do
    alter table("snitch_products") do
      remove :upn
      add(:upi, :string)
    end

    create unique_index("snitch_products", [:upi])
  end
end
