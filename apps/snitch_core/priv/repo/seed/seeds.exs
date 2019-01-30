# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Snitch.Core.Tools.MultiTenancy.Repo.insert!(%Snitch.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Snitch.Core.Tools.MultiTenancy.Repo

alias Snitch.Seed.{
  GeneralConfiguration,
  CountryState,
  PaymentMethods,
  OptionType,
  VariationTheme,
  Orders,
  Users,
  Stocks,
  Taxonomy,
  Role,
  Shipping,
  Product,
  StockLocation,
  ProductRating,
  ShippingRules,
  Tax
}

alias Snitch.Tools.Helper.Taxonomy, as: TaxonomyHelper

variant_count = 9

# seeds general settings for the store.
GeneralConfiguration.seed!()
# seeds the taxonomy
# Taxonomy.seed()
# seeds countries and states entity
Repo.transaction(fn ->
  CountryState.seed_countries!()
  CountryState.seed_states!()
end)

# seed payment methods
# PaymentMethods.seed!()

# seed roles
Role.seed()

OptionType.seed!()

VariationTheme.seed!()

# Users.seed_address!()
Users.seed_users!()

Shipping.seed!()

ShippingRules.seed!()

StockLocation.seed!()

# Repo.transaction(fn ->
#   Orders.seed_variants!()
#   Orders.seed_orders!()
# end)

# Stocks.seed!()

# seed products
# Product.seed()

# seeds a product rating and it's types
ProductRating.seed()

TaxonomyHelper.create_taxonomy({"Category", []})
Tax.seed()
