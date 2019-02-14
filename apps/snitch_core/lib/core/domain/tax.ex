defmodule Snitch.Domain.Tax do
  @moduledoc """
  Exposes functions related to Tax Calculation for
  product and shipping.
  """

  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Domain.Calculator.DefaultTaxCalculator, as: TaxCalculator
  alias Snitch.Data.Schema.{Order, StockLocation, TaxZone, StateZoneMember, CountryZoneMember}
  alias Snitch.Data.Model.{TaxConfig, Product}
  alias Snitch.Data.Model.TaxZone, as: TaxZoneModel
  import Ecto.Query

  @doc """
  Returns a map with original price and the tax.
  ```
    %{
      original_price: price,
      tax: tax_amount
    }
  ```

  Calculates tax for a package item or shipping cost associated
  with a package.
  """

  @spec calculate(atom, any, Order.t(), StockLocation.t()) :: map
  def calculate(:package_item, line_item, order, stock_location) do
    line_item = Repo.preload(line_item, :product)

    tax_class_id = Product.get_tax_class_id(line_item.product)
    tax_config = TaxConfig.get_default()
    tax_address = get_tax_address(order, stock_location, tax_config)
    tax_zone = get_tax_zone!(tax_address)
    calculate_item_tax(tax_zone, line_item, tax_config, tax_class_id)
  end

  def calculate(:shipping, shipping_cost, order, stock_location) do
    tax_config = TaxConfig.get_default()
    tax_address = get_tax_address(order, stock_location, tax_config)
    tax_zone = get_tax_zone!(tax_address)

    calculate_shipping_tax(tax_zone, shipping_cost, tax_config)
  end

  ################# package item tax calulation related helpers ###############

  defp calculate_item_tax(nil, line_item, tax_config, tax_class_id) do
    tax_zone = TaxZoneModel.get_default()
    calculate_item_tax(tax_zone, line_item, tax_config, tax_class_id)
  end

  defp calculate_item_tax(tax_zone, line_item, tax_config, tax_class_id) do
    with tax_rates when tax_rates != [] <- tax_zone.tax_rates do
      amount_with_taxes =
        Enum.map(tax_rates, fn tax_rate ->
          tax_by_rate_and_class(tax_rate, tax_class_id, line_item.unit_price, tax_config)
        end)

      amount_with_tax = List.first(amount_with_taxes)

      total_tax =
        amount_with_taxes
        |> Enum.reduce(Money.new!(line_item.unit_price.currency, 0), fn %{tax: tax}, acc ->
          Money.add!(acc, tax)
        end)
        |> Money.mult!(line_item.quantity)

      %{original_amount: amount_with_tax.amount, tax: total_tax}
    else
      [] ->
        %{
          original_amount: line_item.unit_price,
          tax: Money.new!(line_item.unit_price.currency, 0)
        }
    end
  end

  ######################## shipping tax helpers ###############################

  # If supplied tax_zone is nil then default tax zone is used for
  # calculation
  defp calculate_shipping_tax(_tax_zone = nil, shipping_cost, tax_config) do
    tax_zone = TaxZoneModel.get_default()
    calculate_shipping_tax(tax_zone, shipping_cost, tax_config)
  end

  defp calculate_shipping_tax(tax_zone, shipping_cost, tax_config) do
    with tax_rates when tax_rates != [] <- tax_zone.tax_rates do
      amount_with_taxes =
        Enum.map(tax_rates, fn tax_rate ->
          tax_by_rate_and_class(tax_rate, tax_config.shipping_tax_id, shipping_cost, tax_config)
        end)

      total_tax =
        Enum.reduce(amount_with_taxes, Money.new!(shipping_cost.currency, 0), fn %{tax: tax},
                                                                                 acc ->
          Money.add!(acc, tax)
        end)

      amount_with_tax = List.first(amount_with_taxes)
      %{original_amount: amount_with_tax.amount, tax: total_tax}
    else
      [] ->
        %{original_amount: shipping_cost, tax: Money.new!(shipping_cost.currency, 0)}
    end
  end

  ################# tax calculation helpers ###########################

  defp tax_by_rate_and_class(tax_rate, tax_class_id, price, tax_config) do
    tax_value =
      Enum.find(tax_rate.tax_rate_class_values, fn value ->
        value.tax_class.id == tax_class_id
      end)

    compute_tax(tax_value, price, tax_config)
  end

  defp compute_tax(nil, price, _tax_config) do
    %{amount: price, tax: Money.new!(price.currency, 0)}
  end

  defp compute_tax(tax_value, price, tax_config) do
    TaxCalculator.compute(tax_value.percent_amount, price, tax_config.included_in_price?)
  end

  ################### tax zone related helpers ######################

  # Returns tax zone for the supplied country id.
  defp get_tax_zone!(%{state_id: nil, country_id: country_id}) do
    query =
      from(tz in TaxZone,
        join: c_z_member in CountryZoneMember,
        on: tz.zone_id == c_z_member.zone_id,
        where: c_z_member.country_id == ^country_id and tz.is_active? == true,
        select: %TaxZone{id: tz.id, name: tz.name, zone_id: tz.zone_id}
      )

    tax_zone_query_result(query)
  end

  # Tries to find a tax zone by the state_id if none are found then tries
  # to find using the country_id.
  defp get_tax_zone!(%{state_id: state_id, country_id: country_id}) do
    query =
      from(tz in TaxZone,
        join: s_z_member in StateZoneMember,
        on: tz.zone_id == s_z_member.zone_id,
        where: s_z_member.state_id == ^state_id,
        select: %TaxZone{id: tz.id, name: tz.name}
      )

    tax_zone_query_result(query) || get_tax_zone!(%{state_id: nil, country_id: country_id})
  end

  defp tax_zone_query_result(query) do
    case Repo.all(query) do
      [] ->
        nil

      [tax_zone] ->
        Repo.preload(tax_zone, tax_rates: [tax_rate_class_values: :tax_class])
    end
  end

  ################ address related helpers #########################

  # Checks for address type set in tax config, and tries to find if, the address
  # set is present in the order or not. In case, order does not have the address
  # set, the default address set in tax config is returned.
  # Returns in the format {state_id: data, country_id: data}, returns
  # nil for values if respective id's are not set.

  defp get_tax_address(order, stock_location, tax_config) do
    get_address(tax_config.calculation_address_type, order, stock_location, tax_config)
  end

  defp get_address(:shipping_address, order, _stock_location, tax_config) do
    {state_id, country_id} =
      if order.shipping_address do
        {order.shipping_address.state_id, order.shipping_address.country_id}
      else
        {tax_config.default_state_id, tax_config.default_country_id}
      end

    %{state_id: state_id, country_id: country_id}
  end

  defp get_address(:billing_address, order, _stock_location, tax_config) do
    {state_id, country_id} =
      if order.billing_address do
        {order.billing_address.state_id, order.billing_address.country_id}
      else
        {tax_config.default_state_id, tax_config.default_country_id}
      end

    %{state_id: state_id, country_id: country_id}
  end

  defp get_address(:store_address, _order, stock_location, _tax_config) do
    %{state_id: stock_location.state_id, country_id: stock_location.country_id}
  end
end
