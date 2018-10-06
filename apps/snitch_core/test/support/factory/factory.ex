defmodule Snitch.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Snitch.Core.Tools.MultiTenancy.Repo

  use Snitch.Factory.{
    Address,
    Product,
    Shipping,
    Stock,
    Taxonomy,
    OptionType,
    Zone,
    Rating,
    VariationTheme,
    ShippingCategory
  }

  alias Snitch.Data.Schema.{
    Address,
    Card,
    CardPayment,
    HostedPayment,
    LineItem,
    Order,
    Payment,
    PaymentMethod,
    Permission,
    Role,
    TaxCategory,
    TaxRate,
    User,
    Variant,
    Product,
    ShippingCategory
  }

  alias Snitch.Core.Tools.MultiTenancy.Repo

  def currency do
    :USD
  end

  def user_factory do
    %User{
      first_name: sequence(:first_name, &"Tony-#{&1}"),
      last_name: sequence(:last_name, &"Stark-#{&1}"),
      email: sequence(:email, &"ceo-#{&1}@stark.com"),
      password_hash: "NOTASECRET",
      role: build(:role)
    }
  end

  def user_with_no_role_factory do
    %{
      "first_name" => sequence(:first_name, &"Snitch-#{&1}"),
      "last_name" => sequence(:last_name, &"Elixir-#{&1}"),
      "email" => sequence(:email, &"minion-#{&1}@snitch.com"),
      "password" => "NOTASECRET",
      "password_confirmation" => "NOTASECRET"
    }
  end

  def random_variant_factory do
    %Product{
      name: sequence(:name, &"Hill's-#{&1}"),
      description: sequence(:description, &"description-#{&1}"),
      slug: sequence(:slug, &"Hill's-#{&1}"),
      selling_price: Money.new("12.99", currency()),
      max_retail_price: Money.new("14.99", currency())
    }
  end

  def variant_factory do
    %Product{
      name: sequence(:name, &"Hill's-#{&1}"),
      description: sequence(:description, &"description-#{&1}"),
      slug: sequence(:slug, &"Hill's-#{&1}"),
      selling_price: Money.new("12.99", currency()),
      max_retail_price: Money.new("14.99", currency())
    }
  end

  def line_item_factory do
    %LineItem{
      order: build(:order),
      product: build(:product),
      quantity: 2,
      unit_price: Money.new("9.99", currency())
    }
  end

  def order_factory do
    %Order{
      number: sequence("order"),
      state: "cart"
    }
  end

  def payment_method_card_factory do
    %PaymentMethod{
      name: "card",
      code: "ccd",
      active?: true,
      provider: CreditCard
    }
  end

  def payment_method_check_factory do
    %PaymentMethod{
      name: "check",
      code: "chk",
      active?: true,
      provider: Check
    }
  end

  def payment_method_hosted_factory do
    %PaymentMethod{
      name: "payubiz",
      code: "hpm",
      active?: true,
      provider: PayuBiz
    }
  end

  def payment_ccd_factory do
    %Payment{
      slug: sequence("card-payment"),
      payment_type: "ccd"
    }
  end

  def payment_chk_factory do
    %Payment{
      slug: sequence("check-payment"),
      payment_type: "chk"
    }
  end

  def payment_hosted_factory do
    %Payment{
      slug: sequence("hosted-payment"),
      payment_type: "hpm"
    }
  end

  def card_payment_factory do
    %CardPayment{
      cvv_response: "V",
      avs_response: "Z"
    }
  end

  def hosted_payment_factory do
    %HostedPayment{
      transaction_id: "abc1234",
      raw_response: %{},
      payment_source: "payubiz"
    }
  end

  def card_factory do
    %Card{
      month: 12,
      year: 2099,
      name_on_card: "Tony Stark",
      brand: "VISA",
      number: "4111111111111111",
      card_name: "My VISA card"
    }
  end

  def tax_category_factory do
    %TaxCategory{
      name: sequence(:tax_category, ["CE_VAT", "GST", "CGST", "AU_VAT"]),
      description: "tax applied",
      is_default?: false,
      tax_code: sequence(:tax_code, ["CE_1", "GST", "CGST", "AU_VAT"]),
      deleted_at: nil
    }
  end

  defp random_price(currency, min, delta) do
    Money.new(currency, "#{:rand.uniform(delta) + min}.99")
  end

  def tax_rate_factory do
    %TaxRate{
      name: sequence(:tax_region, ["North America", "Europe", "India", "China"]),
      value: 0.5,
      included_in_price: false,
      calculator: Snitch.Domain.Calculator.Default
    }
  end

  def role_factory do
    %Role{
      name: sequence("nobody"),
      description: "is like everybody"
    }
  end

  def permission_factory do
    %Permission{
      code: sequence(:code, ["manage_products", "manage_orders", "manage_all"]),
      description: "can manage respective"
    }
  end

  def product_factory do
    %Product{
      name: sequence(:product, &"shoes-nike-#{&1}"),
      description: "awesome products",
      slug: sequence(:slug, &"nike-#{&1}")
    }
  end

  # Associates the address with the user once user schema is corrected
  def user_with_address(_context) do
    %{
      address: insert(:address),
      user: insert(:user)
    }
  end

  def line_items(context) do
    %{variants: vs, order: order} = context
    count = Map.get(context, :line_item_count, min(1, length(vs)))

    line_items =
      vs
      |> Stream.map(fn v ->
        struct(
          LineItem,
          order_id: order.id,
          product_id: v.id,
          quantity: 1,
          unit_price: v.selling_price
        )
      end)
      |> Enum.take(count)
      |> Enum.map(&Repo.insert!/1)

    [line_items: line_items]
  end

  def variants(context) do
    count = Map.get(context, :variant_count, 3)
    [variants: insert_list(count, :product)]
  end

  def orders(context) do
    count = Map.get(context, :order_count, 1)
    [orders: insert_list(count, :order)]
  end

  def payment_methods(_context) do
    [
      card_method: insert(:payment_method_card),
      check_method: insert(:payment_method_check),
      hosted_method: insert(:payment_method_hosted)
    ]
  end

  def payments(context) do
    %{card_method: card_m, check_method: check_m, order: order, hosted_method: hosted_m} = context

    [
      ccd: insert(:payment_ccd, payment_method_id: card_m.id, order_id: order.id),
      chk: insert(:payment_chk, payment_method_id: check_m.id, order_id: order.id),
      hpm: insert(:payment_hosted, payment_method_id: hosted_m.id, order_id: order.id)
    ]
  end

  def cards(context) do
    %{user: user} = context
    card_count = Map.get(context, :card_count, 1)
    [cards: insert_list(card_count, :card, user_id: user.id)]
  end

  def offset_date_by(date, offset_days) do
    {:ok, time} =
      date
      |> DateTime.to_unix()
      |> (&(&1 + offset_days * 60 * 60 * 24)).()
      |> DateTime.from_unix()

    time
  end

  def tax_categories(context) do
    count = Map.get(context, :tax_category_count, 3)
    [tax_categories: insert_list(count, :tax_category)]
  end

  def tax_rate(_context) do
    tc = insert(:tax_category)
    zone = insert(:zone, %{zone_type: "S"})
    [tax_rate: insert(:tax_rate, %{tax_category_id: tc.id, zone_id: zone.id})]
  end

  def tax_rates(context) do
    tc = insert(:tax_category)
    zone = insert(:zone, %{zone_type: "S"})
    count = Map.get(context, :tax_rate_count, 3)
    [tax_rates: insert_list(count, :tax_rate, %{tax_category_id: tc.id, zone_id: zone.id})]
  end

  def permissions(context) do
    count = Map.get(context, :permission_count, 2)
    [permissions: insert_list(count, :permission)]
  end
end
