defmodule Snitch.Repo.Migrations.CreateCardTable do
  use Ecto.Migration

  def change do
    create table(:snitch_cards) do
      add(:user_id, references(:snitch_users, on_delete: :delete_all), null: false)
      add(:brand, :string, null: false)
      add(:month, :integer, null: false)
      add(:year, :integer, null: false)
      add(:number, :string, size: 19, null: false)
      add(:name_on_card, :string, null: false)
      add(:is_disabled, :boolean, default: false)
      add(:card_name, :string)
      timestamps()
    end
  end
end
