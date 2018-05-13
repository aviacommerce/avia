alias Snitch.Repo
alias Snitch.Seed.{CountryState, PaymentMethods, Orders, Users, Taxonomy}

# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Snitch.Repo.insert!(%Snitch.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Snitch.Repo
alias Snitch.Seed.{CountryState, PaymentMethods, Orders, Users, Stocks}

variant_count = 9

# seeds countries and states entity
Repo.transaction(fn ->
  CountryState.seed_countries!()
  CountryState.seed_states!()
end)

# seed payment methods
PaymentMethods.seed!()

Users.seed_address!()
Users.seed_users!()

Repo.transaction(fn ->
  Orders.seed_variants!(variant_count)
  Orders.seed_orders!()
end)

Stocks.seed_stock_locations!()

# seeds the taxonomy
Taxonomy.seed()
