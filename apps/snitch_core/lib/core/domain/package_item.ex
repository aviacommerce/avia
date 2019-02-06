defmodule Snitch.Domain.PackageItem do
  @moduledoc """
  PackageItem helpers.
  """

  alias Snitch.Data.Schema.{PackageItem, StockLocation}
  alias Snitch.Tools.Money, as: MoneyTools
  alias Snitch.Domain.Tax

  @spec tax(PackageItem.t(), StockLocation.t()) :: Money.t()
  def tax(_package_item, _stock_location) do
    MoneyTools.zero!()
  end

  @spec shipping_tax(PackageItem.t(), StockLocation.t()) :: Money.t()
  def shipping_tax(_package_item, _stock_location) do
    MoneyTools.zero!()
  end

  @doc """
  Returns the unit price and tax for a package item in the following
  format %{original_amount: price, tax: tax_value}
  """
  def unit_price_with_tax(lineitem, order, stock_location) do
    Tax.calculate(:package_item, lineitem, order, stock_location)
  end
end
