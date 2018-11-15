defmodule Snitch.Repo.Migrations.AddPricesToVariants do
  use Ecto.Migration

  # cost_price, selling_price need to be not-null
  # sku default made absolutely no sense (since it has to be unique)
  # defaults are a bad idea in general (weight default removed)
  def change do
    alter table(:snitch_variants) do
      remove :is_master
      add :selling_price, String.to_atom("money_with_currency"), null: false
      modify :cost_price, String.to_atom("money_with_currency"), null: false
      modify :sku, :string, null: false
      modify :weight, :decimal, precision: 8, scale: 2
    end
  end
end
