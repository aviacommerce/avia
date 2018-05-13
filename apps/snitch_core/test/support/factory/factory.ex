defmodule Snitch.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Snitch.Repo
  use Snitch.Factory.{Address, Stock, Zone, Shipping, Taxonomy}

  alias Snitch.Data.Schema.{
    Variant,
    Address,
    User,
    LineItem,
    Order,
    Payment,
    PaymentMethod,
    CardPayment,
    Card,
    TaxCategory
  }

  alias Snitch.Repo

  def user_factory do
    %User{
      first_name: sequence(:first_name, &"Tony-#{&1}"),
      last_name: sequence(:last_name, &"Stark-#{&1}"),
      email: sequence(:email, &"ceo-#{&1}@stark.com"),
      password_hash: "NOTASECRET"
    }
  end

  def random_variant_factory do
    %Variant{
      sku: sequence(:sku, &"shoes-nike-#{&1}"),
      weight: Decimal.new("0.45"),
      height: Decimal.new("0.15"),
      depth: Decimal.new("0.1"),
      width: Decimal.new("0.4"),
      cost_price: Money.new("9.99", :USD),
      selling_price: random_price(14, 4)
    }
  end

  def variant_factory do
    %Variant{
      sku: sequence(:sku, &"shoes-nike-#{&1}"),
      weight: Decimal.new("0.45"),
      height: Decimal.new("0.15"),
      depth: Decimal.new("0.1"),
      width: Decimal.new("0.4"),
      cost_price: Money.new("9.99", :USD),
      selling_price: Money.new("14.99", :USD)
    }
  end

  def order_factory do
    %Order{
      slug: sequence("order"),
      state: "cart",
      adjustment_total: Money.new(0, :USD),
      promo_total: Money.new(0, :USD),
      item_total: Money.new(0, :USD),
      total: Money.new(0, :USD)
    }
  end

  def payment_method_card_factory do
    %PaymentMethod{
      name: "card",
      code: "ccd",
      active?: true
    }
  end

  def payment_method_check_factory do
    %PaymentMethod{
      name: "check",
      code: "chk",
      active?: true
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

  def card_payment_factory do
    %CardPayment{
      cvv_response: "V",
      avs_response: "Z"
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
      name: sequence(:name, ["CE_VAT", "GST", "CGST", "AU_VAT"]),
      description: "tax applied",
      is_default?: false,
      tax_code: sequence(:tax_code, ["CE_1", "GST", "CGST", "AU_VAT"]),
      deleted_at: nil
    }
  end

  defp random_price(min, delta) do
    Money.new(:USD, "#{:rand.uniform(delta) + min}.99")
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
          variant_id: v.id,
          quantity: 1,
          unit_price: v.cost_price,
          total: v.cost_price
        )
      end)
      |> Enum.take(count)
      |> Enum.map(&Repo.insert!/1)

    [line_items: line_items]
  end

  def variants(context) do
    count = Map.get(context, :variant_count, 3)
    [variants: insert_list(count, :random_variant)]
  end

  def an_order(context) do
    %{user: user} = context
    [order: insert(:order, user_id: user.id)]
  end

  def payment_methods(_context) do
    [
      card_method: insert(:payment_method_card),
      check_method: insert(:payment_method_check)
    ]
  end

  def payments(context) do
    %{card_method: card_m, check_method: check_m, order: order} = context

    [
      ccd: insert(:payment_ccd, payment_method_id: card_m.id, order_id: order.id),
      chk: insert(:payment_chk, payment_method_id: check_m.id, order_id: order.id)
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
end
