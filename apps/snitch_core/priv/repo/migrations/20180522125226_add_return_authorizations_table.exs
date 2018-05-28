defmodule Snitch.Repo.Migrations.AddReturnAuthorizationsTable do
  use Ecto.Migration

  def change do
    create table(:snitch_return_authorizations) do
      add :number, :string, null: false
      add :state, :string
      add :order_id, references(:snitch_orders, on_delete: :delete_all)
      add :memo, :text
      add :return_authorization_reason_id, references(:snitch_return_authorization_reasons)

      timestamps()
    end

    create index(:snitch_return_authorizations, [:order_id])
    create unique_index(:snitch_return_authorizations, [:number])
  end
end
