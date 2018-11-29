defmodule Snitch.Domain.PackageItemTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Mox, only: [expect: 3, verify_on_exit!: 1]

  alias Snitch.Domain.PackageItem
  alias Snitch.Data.Model.GeneralConfiguration, as: GCModel

  setup :verify_on_exit!

  test "tax/1" do
    currency = GCModel.fetch_currency()
    assert PackageItem.tax(nil, nil) == Money.zero(currency)
  end

  test "shipping_tax/1" do
    currency = GCModel.fetch_currency()
    assert PackageItem.shipping_tax(nil, nil) == Money.zero(currency)
  end
end
