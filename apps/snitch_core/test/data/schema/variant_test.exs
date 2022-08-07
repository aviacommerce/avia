# Variant will not used as we now are using self referential products

# defmodule Snitch.Data.Schema.VariantTest do
#   use ExUnit.Case, async: true
#   use Snitch.DataCase
#
#   import Snitch.Factory
#
#   alias Snitch.Data.Schema.Variant
#   alias Snitch.Core.Tools.MultiTenancy.Repo
#
#   @valid_params %{
#     sku: "shoes-nike-sz-9",
#     weight: Decimal.new("0.45"),
#     height: Decimal.new("0.15"),
#     depth: Decimal.new("0.1"),
#     width: Decimal.new("0.4"),
#     cost_price: Money.new("9.99", :USD),
#     selling_price: Money.new("14.99", :USD),
#     discontinue_on: offset_date_by(DateTime.utc_now(), 365)
#   }
#
#   describe "variant creation" do
#     test "with valid params" do
#       %{valid?: validity} = changeset = Variant.create_changeset(%Variant{}, @valid_params)
#       assert validity
#       assert {:ok, _} = Repo.insert(changeset)
#     end
#
#     test "fails with missing fields" do
#       params = Map.drop(@valid_params, ~w[cost_price selling_price sku]a)
#       cs = %{valid?: validity} = Variant.create_changeset(%Variant{}, params)
#       refute validity
#
#       assert %{
#                cost_price: ["can't be blank"],
#                selling_price: ["can't be blank"],
#                sku: ["can't be blank"]
#              } = errors_on(cs)
#     end
#
#     test "fails with bad selling price" do
#       params = %{@valid_params | selling_price: Money.new("-0.01", :USD)}
#       cs = %{valid?: validity} = Variant.create_changeset(%Variant{}, params)
#       refute validity
#       assert %{selling_price: ["must be equal or greater than 0"]} = errors_on(cs)
#     end
#
#     test "fails with bad cost price" do
#       params = %{@valid_params | cost_price: Money.new("-0.01", :USD)}
#       cs = %{valid?: validity} = Variant.create_changeset(%Variant{}, params)
#       refute validity
#       assert %{cost_price: ["must be equal or greater than 0"]} = errors_on(cs)
#     end
#
#     test "fails with duplicate sku" do
#       variant = insert(:variant)
#       params = %{@valid_params | sku: variant.sku}
#       changeset = Variant.create_changeset(%Variant{}, params)
#       assert {:error, cs} = Repo.insert(changeset)
#       assert %{sku: ["has already been taken"]} = errors_on(cs)
#     end
#
#     test "fails with invalid discontinue_on" do
#       params = %{@valid_params | discontinue_on: DateTime.utc_now()}
#       cs = %{valid?: validity} = Variant.create_changeset(%Variant{}, params)
#       refute validity
#
#       assert %{discontinue_on: ["date should be in future"]} = errors_on(cs)
#     end
#   end
# end
