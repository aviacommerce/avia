defmodule Snitch.Repo.Migrations.CreateCardTable do
  use Ecto.Migration

  def change do
    create table(:snitch_cards) do
      add(:user_id, references(:snitch_users, on_delete: :delete_all), null: false)
      add(:brand, :string, null: false)
      add(:month, :integer, null: false)
      add(:year, :integer, null: false)
      add(:last_digits, :string, size: 4, null: false)
      add(:name_on_card, :string, null: false)
      add(:card_name, :string)
      add(:address_id, references(:snitch_addresses))

      timestamps()
    end
  end
end
