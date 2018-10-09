defmodule Snitch.Repo.Migrations.AddStateToProduct do
  use Ecto.Migration

  def change do
    alter table("snitch_products") do
      add :state, :string, null: false, default: "draft"
    end
  end
end
