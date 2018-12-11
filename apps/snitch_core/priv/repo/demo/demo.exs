alias Snitch.Demo.{
  OptionType,
  Order,
  PaymentMethod,
  Product,
  StockLocation,
  Taxonomy,
  User,
  VariationTheme
}

User.create_users()
OptionType.create_option_types()
PaymentMethod.create_payment_methods()
StockLocation.create_stock_locations()
VariationTheme.create_variation_themes()
Taxonomy.create_taxonomy()
Product.create_products()
Order.create_orders()
