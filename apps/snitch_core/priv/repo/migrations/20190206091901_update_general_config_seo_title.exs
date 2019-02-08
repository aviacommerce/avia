defmodule Snitch.Repo.Migrations.UpdateGeneralConfigSeoTitle do
  use Ecto.Migration

  def change do
    alter table("snitch_general_configurations") do
      modify :seo_title, :string, null: true
      modify :frontend_url, :string, null: true
      modify :backend_url, :string, null: true
    end
  end
end
