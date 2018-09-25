defmodule Snitch.Repo.Migrations.SnitchGeneralConfigurations do
  use Ecto.Migration

  def change do
    create table("snitch_general_configurations") do
      add :name, :string, null: false, default: ""
      add :meta_description, :string, null: false, default: ""
      add :meta_keywords, :string, null: false, default: ""
      add :seo_title, :string, null: false, default: ""
      add :sender_mail, :string, null: false, default: ""
      add :sendgrid_api_key, :string, null: false, default: ""
      add :currency, :string, null: false, default: ""

      timestamps()
    end
  end
end
