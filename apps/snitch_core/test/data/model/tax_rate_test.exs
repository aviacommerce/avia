defmodule Snitch.Data.Model.TaxRateTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Mox
  import Snitch.Factory

  alias Snitch.Data.Model.TaxRate, as: TaxRateModel
  alias Snitch.Data.Schema.TaxRate

  @valid_params %{
    name: "Europe",
    value: 0.5,
    included_in_price: false,
    calculator: Snitch.Domain.Calculator.Default
  }

  setup :calculator_setup

  describe "create/1" do
    setup :create_tax_params

    test "tax rate successfully", context do
      %{tax_rate_params: params} = context
      assert {:ok, _} = TaxRateModel.create(params)
    end

    test "fails name missing", context do
      %{tax_rate_params: params} = context
      params = Map.drop(params, [:name])
      assert {:error, cs} = TaxRateModel.create(params)
      assert %{name: ["can't be blank"]} = errors_on(cs)
    end

    test "fails calculator missing", context do
      %{tax_rate_params: params} = context
      params = Map.drop(params, [:calculator])
      assert {:error, cs} = TaxRateModel.create(params)
      assert %{calculator: ["can't be blank"]} = errors_on(cs)
    end
  end

  describe "update/2" do
    setup :tax_rate

    test "failed invalid calculator", context do
      params = %{calculator: BinaryCalculator}
      %{tax_rate: tr} = context
      assert {:error, cs} = TaxRateModel.update(params, tr)
      assert %{calculator: ["invalid calculator"]} = errors_on(cs)
    end

    test "failed name missing", context do
      %{tax_rate: tr} = context
      params = %{name: "", id: tr.id}
      assert {:error, cs} = TaxRateModel.update(params)
      assert %{name: ["can't be blank"]} = errors_on(cs)
    end
  end

  describe "delete/1" do
    setup :tax_rate

    test "tax category successfully", context do
      %{tax_rate: tr} = context
      assert {:ok, tr_deleted} = TaxRateModel.delete(tr)
      refute is_nil(tr_deleted.deleted_at)
      tr_received = Repo.get(TaxRate, tr_deleted.id)
      refute is_nil(tr_received)
    end
  end

  describe "get/2" do
    setup :tax_rate

    test "tax rate", context do
      %{tax_rate: tr} = context
      tr_ret = TaxRateModel.get(tr.id)
      assert tr.id == tr_ret.id
    end

    test "no tax rate is deleted", context do
      %{tax_rate: tr} = context
      assert {:ok, tr} = TaxRateModel.delete(tr)
      refute is_nil(tr.deleted_at)
      tr_ret = TaxRateModel.get(tr.id)
      assert is_nil(tr_ret)
    end

    test "tax category is deleted", context do
      %{tax_rate: tr} = context
      {:ok, tr} = TaxRateModel.delete(tr)
      refute is_nil(tr.deleted_at)
      tr_ret = TaxRateModel.get(tr.id, false)
      refute is_nil(tr_ret)
    end
  end

  describe "get_all/1" do
    setup :tax_rates

    @tag tax_rate_count: 2
    test "tax categories" do
      tax_rates = TaxRateModel.get_all()
      assert length(tax_rates) == 2
      assert {:ok, _} = TaxRateModel.delete(List.first(tax_rates))
      tax_rates = TaxRateModel.get_all()
      assert length(tax_rates) == 1
    end

    @tag tax_rate_count: 2
    test "tax categories including soft deleted" do
      tax_rates = TaxRateModel.get_all()
      assert length(tax_rates) == 2
      assert {:ok, _} = TaxRateModel.delete(List.first(tax_rates))
      tax_rates = TaxRateModel.get_all(false)
      assert length(tax_rates) == 2
    end

    test "tax categories for no record" do
      Repo.delete_all(TaxRate)
      tax_rates = TaxRateModel.get_all()
      assert tax_rates == []
    end
  end

  defp create_tax_params(_context) do
    tc = insert(:tax_category)
    zone = insert(:zone, zone_type: "S")

    params =
      @valid_params
      |> Map.put(:tax_category_id, tc.id)
      |> Map.put(:zone_id, zone.id)

    [zone: zone, tax_category: tc, tax_rate_params: params]
  end

  defp calculator_setup(_context) do
    expect(Snitch.Tools.DefaultsMock, :fetch, fn :calculators ->
      {:ok, [Snitch.Domain.Calculator.Default]}
    end)

    expect(Snitch.Tools.UserConfigMock, :get, fn :calculators ->
      [FlatRateCalculator, FixRateCalculator]
    end)

    :ok
  end
end
