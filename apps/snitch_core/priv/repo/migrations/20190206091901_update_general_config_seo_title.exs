defmodule Snitch.Repo.Migrations.UpdateGeneralConfigSeoTitle do
  use Ecto.Migration

  def change do
    alter table("snitch_general_configurations") do
      remove :seo_title
      remove :frontend_url
      remove :backend_url
      add :seo_title, :string, default: ""
      add :frontend_url, :string, default: ""
      add :backend_url, :string, default: ""
    end
  end
end
