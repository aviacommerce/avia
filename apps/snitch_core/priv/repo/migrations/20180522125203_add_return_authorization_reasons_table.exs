defmodule Snitch.Repo.Migrations.AddReturnAuthorizationReasonsTable do
  use Ecto.Migration

  def change do
    create table(:snitch_return_authorization_reasons) do
      add :name, :string
      add :active, :boolean, default: true

      timestamps()
    end

    create unique_index(:snitch_return_authorization_reasons, [:name])
  end
end
