defmodule Core.Snitch.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: Core.Repo
  alias Core.Snitch.{User, Address, Variant}
  alias Core.Snitch.Data.Schema.{Order}

  @iron_patriot %Variant{
    sku: "iron-patriot",
    weight: Decimal.new(128),
    height: Decimal.new("1.8288"),
    depth: Decimal.new(1),
    width: Decimal.new(2),
    is_master: true,
    cost_price: Money.new("699599.99", :USD)
  }

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

  def basic_order_factory() do
    %Order{
      slug: sequence("order"),
      state: "cart"
    }
  end

  def checkout_repo(context) do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Core.Repo)
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
end
