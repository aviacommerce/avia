alias Snitch.Data.Schema.{User, Address, Order, Variant, LineItem, CardPayment}
alias Snitch.Data.Model
alias Snitch.Domain.Order.Machine
alias Snitch.Repo
alias BeepBop.Context

Repo.delete_all(Order)
Repo.delete_all(Variant)
Repo.delete_all(User)

variants = [
  %{
    cost_price: Money.new(:USD, "12.99000000"),
    depth: Decimal.new("0.10"),
    height: Decimal.new("0.15"),
    sku: "shoes-nike-0",
    weight: Decimal.new("0.45"),
    width: Decimal.new("0.40")
  },
  %{
    cost_price: Money.new(:USD, "11.99000000"),
    depth: Decimal.new("0.10"),
    height: Decimal.new("0.15"),
    sku: "shoes-nike-1",
    weight: Decimal.new("0.45"),
    width: Decimal.new("0.40")
  },
  %{
    cost_price: Money.new(:USD, "15.99000000"),
    depth: Decimal.new("0.10"),
    height: Decimal.new("0.15"),
    sku: "shoes-nike-2",
    weight: Decimal.new("0.45"),
    width: Decimal.new("0.40")
  }
]
|> Stream.map(&Variant.changeset(%Variant{}, &1))
|> Stream.map(&Repo.insert/1)
|> Enum.map(fn {:ok, o} -> o end)

line_items =
  variants
  |> Stream.map(fn x -> x.id end)
  |> Enum.into([], fn variant_id ->
    %{variant_id: variant_id, quantity: 2}
  end)

{:ok, user} = Model.User.create(%{
  first_name: "Tony",
  last_name: "Stark",
  email: "ceo@stark.com",
  password: "NOTASECRET",
  password_confirmation: "NOTASECRET"})

address_cs = Address.changeset(%Address{}, %{
      first_name: "Tony",
      last_name: "Stark",
      address_line_1: "10-8-80 Malibu Point",
      zip_code: "90265",
      city: "Malibu",
      phone: "1234567890"})

{:ok, order} = Model.Order.create(%{slug: "d", user_id: user.id}, line_items)
c = Context.new(order, %{billing_cs: address_cs, shipping_cs: address_cs})

# {:ok, %{persist: o}} = Machine.add_addresses(c)
# {:ok, %{persist: o}} = Machine.add_payment(Context.new(o, %{}))

# context_struct = Machine.add_payment(Context.new(o, %{}), persist: false)

# {:ok, %{persist: o}} = OrderMachine.confirmed %{order: o, card_payment: %CardPayment{}}
# {:ok, %{persist: o}} = Checkout.payment_successful o, %Snitch.Data.Schema.Payment{}
