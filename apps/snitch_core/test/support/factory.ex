defmodule Snitch.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: Snitch.Repo
  alias Snitch.Data.Schema.{Variant, Address, User, Order}

  def user_factory() do
    %User{
      first_name: sequence(:first_name, &"Tony-#{&1}"),
      last_name: sequence(:last_name, &"Stark-#{&1}"),
      email: sequence(:email, &"ceo-#{&1}@stark.com")
    }
  end

  def address_factory() do
    %Address{
      first_name: sequence(:first_name, &"Tony-#{&1}"),
      last_name: sequence(:last_name, &"Stark-#{&1}"),
      address_line_1: "10-8-80 Malibu Point",
      zip_code: "90265",
      city: "Malibu",
      phone: "1234567890"
      # state_id: State.get_id("California"),
      # country_id: Country.get_id("USA"),
    }
  end

  def random_variant_factory() do
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

  def variant_factory() do
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

  def order_factory() do
    %Order{
      slug: sequence("order"),
      state: "cart"
    }
  end

  def payment_method_card_factory() do
    %PaymentMethod{
      name: "card",
      code: "ccd",
      active?: true
    }
  end

  def payment_method_check_factory() do
    %PaymentMethod{
      name: "check",
      code: "chk",
      active?: true
    }
  end

  def payment_ccd_factory() do
    %Payment{
      slug: sequence("card-payment"),
      payment_type: "ccd"
    }
  end

  def payment_chk_factory() do
    %Payment{
      slug: sequence("check-payment"),
      payment_type: "chk"
    }
  end

  def card_payment_factory() do
    %CardPayment{
      cvv_response: "V",
      avs_response: "Z"
    }
  end

  def checkout_repo(context) do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Snitch.Repo)
    context
  end

  defp random_price(min, delta) do
    Money.new(:USD, "#{:rand.uniform(delta) + min}.99")
  end

  def a_user_and_address(context) do
    inserts = %{
      user: insert(:user),
      address: insert(:address)
    }

    Map.merge(context, inserts)
  end

  def three_variants(context) do
    Map.put(context, :variants, insert_list(3, :random_variant))
  end

  def an_order(context) do
    %{user: user} = context
    order = insert(:order, user_id: user.id)

    Map.put(context, :order, order)
  end

  def payment_methods(context) do
    card = insert(:payment_method_card)
    check = insert(:payment_method_check)

    context
    |> Map.put(:card_method, card)
    |> Map.put(:check_method, check)
  end

  def payments(context) do
    %{card_method: card_m, check_method: check_m, order: order} = context
    card = insert(:payment_ccd, payment_method_id: card_m.id, order_id: order.id)
    check = insert(:payment_chk, payment_method_id: check_m.id, order_id: order.id)
    card_payment = insert(:card_payment, payment_id: card.id)

    context
    |> Map.put(:ccd, card)
    |> Map.put(:chk, check)
    |> Map.put(:card, card_payment)
  end
end
