defmodule Snitch.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Snitch.Repo
  use Snitch.Factory.{Address, Stock, Zone, Shipping}

  alias Snitch.Data.Schema.{Variant, Address, User, Order, Payment, PaymentMethod, CardPayment}

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
      is_master: true,
      cost_price: random_price(9, 9)
    }
  end

  def variant_factory do
    %Variant{
      sku: sequence(:sku, &"shoes-nike-#{&1}"),
      weight: Decimal.new("0.45"),
      height: Decimal.new("0.15"),
      depth: Decimal.new("0.1"),
      width: Decimal.new("0.4"),
      is_master: true,
      cost_price: Money.new("9.99", :USD)
    }
  end

  def order_factory do
    %Order{
      slug: sequence("order"),
      state: "cart"
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

  def three_variants(_context) do
    [variants: insert_list(3, :random_variant)]
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
    ccd = insert(:payment_ccd, payment_method_id: card_m.id, order_id: order.id)
    chk = insert(:payment_chk, payment_method_id: check_m.id, order_id: order.id)

    [
      ccd: ccd,
      chk: chk,
      card: insert(:card_payment, payment_id: ccd.id)
    ]
  end
end
