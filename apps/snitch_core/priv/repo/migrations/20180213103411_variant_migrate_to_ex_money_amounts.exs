defmodule Core.Repo.Migrations.VariantMigrateToExMoneyAmounts do
  use Ecto.Migration

  def change do
    alter table(:snitch_variants) do
      remove :cost_currency
      remove :cost_price
      add :cost_price, String.to_atom("money_with_currency")
    end
  end
end
