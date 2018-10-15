defmodule Snitch.Data.Schema.TaxRateTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory
  import Mox

  alias Snitch.Data.Schema.TaxRate
  alias Snitch.Core.Tools.MultiTenancy.Repo

  @valid_params %{
    name: "North America",
    value: 0.5,
    included_in_price: false,
    calculator: Snitch.Calculator.Calculator.Default
  }

  setup :tax_rate_params
  setup :calculator_setup

  describe "creation" do
    test "with valid params", context do
      %{tax_rate_params: params} = context
      changeset = %{valid?: validity} = TaxRate.create_changeset(%TaxRate{}, params)
      assert validity
      assert {:ok, _} = Repo.insert(changeset)
    end

    test "unsuccessful, missing required params", context do
      %{tax_rate_params: params} = context
      params = Map.drop(params, [:tax_category_id])
      %{valid?: validity} = TaxRate.create_changeset(%TaxRate{}, params)
      refute validity
    end
  end

  describe "updation" do
    test "update tax rate name" do
      tc = insert(:tax_category)
      zone = insert(:zone, %{zone_type: "S"})
      tax_rate = insert(:tax_rate, %{tax_category_id: tc.id, zone_id: zone.id})

      params = %{name: "Europe"}
      %{valid?: validity} = TaxRate.update_changeset(tax_rate, params)
      assert validity
    end
  end

  defp tax_rate_params(_context) do
    zone = insert(:zone, zone_type: "S")
    tax_category = insert(:tax_category)

    params =
      @valid_params
      |> Map.put(:tax_category_id, tax_category.id)
      |> Map.put(:zone_id, zone.id)

    [tax_rate_params: params]
  end

  defp calculator_setup(_context) do
    expect(Snitch.Tools.DefaultsMock, :fetch, fn :calculators ->
      {:ok, [Snitch.Calculator.Calculator.Default]}
    end)

    expect(Snitch.Tools.UserConfigMock, :get, fn :calculators ->
      [FlatRateCalculator, FixRateCalculator]
    end)

    :ok
  end
end
