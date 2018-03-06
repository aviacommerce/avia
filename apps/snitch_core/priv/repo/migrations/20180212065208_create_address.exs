defmodule Core.Repo.Migrations.CreateAddress do
  use Ecto.Migration

  def change do
    create table(:snitch_addresses) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :address_line_1, :string, null: false
      add :address_line_2, :string
      add :city, :string
      add :zip_code, :string, null: false
      add :phone, :string
      add :alternate_phone, :string
      timestamps()
    end
  end
end
