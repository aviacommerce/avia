defmodule Snitch.Domain.PackageItemTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Mox, only: [expect: 3, verify_on_exit!: 1]

  alias Snitch.Domain.PackageItem

  setup :verify_on_exit!

  test "tax/1" do
    expect(Snitch.Tools.DefaultsMock, :fetch, fn :currency -> {:ok, :INR} end)
    assert PackageItem.tax(nil, nil) == Money.zero(:INR)
  end

  test "shipping_tax/1" do
    expect(Snitch.Tools.DefaultsMock, :fetch, fn :currency -> {:ok, :INR} end)
    assert PackageItem.shipping_tax(nil, nil) == Money.zero(:INR)
  end
end
