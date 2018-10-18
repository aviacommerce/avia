defmodule Snitch.Repo.Migrations.AlterSnitchGeneralConfigurations do
  use Ecto.Migration
 
  def change do
    alter table("snitch_general_configurations") do
      remove :meta_description
      remove :meta_keywords
      remove :sendgrid_api_key
      add :frontend_url, :string, null: false, default: ""
      add :backend_url, :string, null: false, default: ""
      add :hosted_payment_url, :string, null: false, default: ""
    end
  end
end
