defmodule Snitch.Domain.PackageItem do
  @moduledoc """
  PackageItem helpers.
  """

  alias Ecto.Changeset
  alias Snitch.Data.Schema.PackageItem
  alias Snitch.Tools.Money, as: MoneyTools

  @spec tax(PackageItem.t()) :: Money.t()
  def tax(package_item) do
    MoneyTools.zero!()
  end

  @spec shipping_tax(PackageItem.t()) :: Money.t()
  def shipping_tax(package_item) do
    MoneyTools.zero!()
  end
end
