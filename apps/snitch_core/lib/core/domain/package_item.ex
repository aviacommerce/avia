defmodule Snitch.Domain.PackageItem do
  @moduledoc """
  PackageItem helpers.
  """

  alias Snitch.Data.Schema.{PackageItem, StockLocation}
  alias Snitch.Tools.Money, as: MoneyTools

  @spec tax(PackageItem.t(), StockLocation.t()) :: Money.t()
  def tax(_package_item, _stock_location) do
    MoneyTools.zero!()
  end

  @spec shipping_tax(PackageItem.t(), StockLocation.t()) :: Money.t()
  def shipping_tax(_package_item, _stock_location) do
    MoneyTools.zero!()
  end
end
