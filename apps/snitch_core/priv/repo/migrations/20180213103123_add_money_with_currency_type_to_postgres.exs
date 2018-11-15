defmodule Core.Repo.Migrations.AddMoneyWithCurrencyTypeToPostgres do
  use Ecto.Migration

  def up do
    execute """
      DO $$ BEGIN
        CREATE TYPE money_with_currency AS (currency_code char(3), amount numeric(20,8));
      EXCEPTION
        WHEN duplicate_object THEN NULL;
      END $$;
    """
  end

  def down do
    execute "DROP TYPE money_with_currency"
  end
end
