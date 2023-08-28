defmodule Snitch.Repo.Migrations.AddPostgresMoneyAggregateFunctions do
  use Ecto.Migration

  def up do
    execute """
      CREATE OR REPLACE FUNCTION money_state_function(agg_state money_with_currency, money money_with_currency)
      RETURNS money_with_currency
      IMMUTABLE
      LANGUAGE plpgsql
      AS $$
        DECLARE
          expected_currency char(3);
          aggregate numeric(20, 8);
          addition numeric(20,8);
        BEGIN
          if currency_code(agg_state) IS NULL then
            expected_currency := currency_code(money);
            aggregate := 0;
          else
            expected_currency := currency_code(agg_state);
            aggregate := amount(agg_state);
          end if;

          IF currency_code(money) = expected_currency THEN
            addition := aggregate + amount(money);
            return row(expected_currency, addition);
          ELSE
            RAISE EXCEPTION
              'Incompatible currency codes. Expected all currency codes to be %', expected_currency
              USING HINT = 'Please ensure all columns have the same currency code',
              ERRCODE = '22033';
          END IF;
        END;
      $$;
    """

    execute """
      DO $$ BEGIN
        CREATE AGGREGATE sum(money_with_currency) (
          sfunc = money_state_function,
          stype = money_with_currency
        );
      EXCEPTION
        WHEN duplicate_function THEN NULL;
      END $$;
    """
  end

  def down do
    execute "DROP AGGREGATE IF EXISTS sum(money_with_currency);"

    execute "DROP FUNCTION IF EXISTS money_state_function(agg_state money_with_currency, money money_with_currency);"
  end
end
