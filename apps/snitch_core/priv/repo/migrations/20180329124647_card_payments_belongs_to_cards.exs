defmodule Snitch.Repo.Migrations.CardPaymentsBelongsToCard do
  use Ecto.Migration

  def change do
    alter table(:snitch_card_payments) do
      add(:card_id, references("snitch_cards"))
    end
  end
end
