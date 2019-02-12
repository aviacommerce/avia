defmodule Snitch.Data.Model.TaxRateTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model.TaxRate

  describe "create/1" do
    test "successfully" do
      tax_class_1 = insert(:tax_class)
      tax_class_2 = insert(:tax_class)

      tax_class_values = [
        %{tax_class_id: tax_class_1.id, percent_amount: 2},
        %{tax_class_id: tax_class_2.id, percent_amount: 3}
      ]

      tax_zone = setup_tax_zone()

      params = %{name: "GST", tax_rate_class_values: tax_class_values, tax_zone_id: tax_zone.id}
      assert {:ok, _data} = TaxRate.create(params)
    end

    test "fails if tax rate exists with same name for the same tax zone" do
      tax_zone = setup_tax_zone()

      tax_rate =
        :tax_rate
        |> insert(tax_zone: tax_zone)
        |> Repo.preload(:tax_rate_class_values)

      tax_class_1 = insert(:tax_class)
      tax_class_2 = insert(:tax_class)

      tax_class_values = [
        %{tax_class_id: tax_class_1.id, percent_amount: 2},
        %{tax_class_id: tax_class_2.id, percent_amount: 3}
      ]

      params = %{
        name: tax_rate.name,
        tax_rate_class_values: tax_class_values,
        tax_zone_id: tax_zone.id
      }

      assert {:error, changeset} = TaxRate.create(params)

      assert %{
               name: ["Tax Rate name should be unique for a tax zone."]
             } == errors_on(changeset)
    end
  end

  describe "update/2" do
    test "success" do
      tax_zone = setup_tax_zone()
      tax_rate = :tax_rate |> insert(tax_zone: tax_zone) |> Repo.preload(:tax_rate_class_values)
      assert tax_rate.tax_rate_class_values == []

      tax_class_1 = insert(:tax_class)
      tax_class_2 = insert(:tax_class)

      tax_class_values = [
        %{tax_class_id: tax_class_1.id, percent_amount: 2},
        %{tax_class_id: tax_class_2.id, percent_amount: 3}
      ]

      params = %{tax_rate_class_values: tax_class_values}

      assert {:ok, updated_tax_rate} = TaxRate.update(tax_rate, params)
      assert updated_tax_rate.tax_rate_class_values != []
    end

    test "fails if any error on changeset" do
      tax_zone = setup_tax_zone()
      tax_rate = :tax_rate |> insert(tax_zone: tax_zone) |> Repo.preload(:tax_rate_class_values)
      assert tax_rate.tax_rate_class_values == []

      tax_class = insert(:tax_class)
      # Deliberately set same tax_class id for two tax_class_values.
      tax_class_values = [
        %{tax_class_id: tax_class.id, percent_amount: 2},
        %{tax_class_id: tax_class.id, percent_amount: 3}
      ]

      params = %{tax_rate_class_values: tax_class_values}

      assert {:error, changeset} = TaxRate.update(tax_rate, params)

      assert %{
               tax_rate_class_values: [%{}, %{tax_rate_id: ["has already been taken"]}]
             } == errors_on(changeset)
    end
  end

  test "delete success" do
    tax_zone = setup_tax_zone()
    tax_class_1 = insert(:tax_class)
    tax_class_2 = insert(:tax_class)

    tax_class_values = [
      %{tax_class_id: tax_class_1.id, percent_amount: 2},
      %{tax_class_id: tax_class_2.id, percent_amount: 3}
    ]

    params = %{name: "GST", tax_zone_id: tax_zone.id, tax_rate_class_values: tax_class_values}
    assert {:ok, tax_rate} = TaxRate.create(params)

    assert {:ok, _data} = TaxRate.delete(tax_rate.id)
  end

  describe "get/1" do
    test "returns for valid id" do
      tax_zone = setup_tax_zone()
      tax_rate = insert(:tax_rate, tax_zone: tax_zone)

      assert {:ok, _tax_rate} = TaxRate.get(tax_rate.id)
    end

    test "returns error if invalid id" do
      assert {:error, message} = TaxRate.get(-1)
      assert message == :tax_rate_not_found
    end
  end

  test "get_all returns a list of tax rates" do
    tax_zone = setup_tax_zone()
    insert(:tax_rate, tax_zone: tax_zone)
    insert(:tax_rate, tax_zone: tax_zone)

    tax_rates = TaxRate.get_all()
    assert length(tax_rates) == 2
  end

  describe "get_all_by_tax_zone/1" do
    test "returns tax rates for given tax zone id" do
      tax_zone_1 = setup_tax_zone()
      insert(:tax_rate, tax_zone: tax_zone_1)

      tax_zone_2 = setup_tax_zone()

      assert data_1 = TaxRate.get_all_by_tax_zone(tax_zone_1.id)
      assert length(data_1) == 1

      assert data_2 = TaxRate.get_all_by_tax_zone(tax_zone_2.id)
      assert data_2 == []
    end
  end

  def setup_tax_zone() do
    zone = insert(:zone, zone_type: "C")
    [countries: countries] = countries(%{state_count: 3})
    setup_country_zone_members(zone, countries)
    insert(:tax_zone, zone: zone)
  end

  defp setup_country_zone_members(zone, countries) do
    Enum.each(countries, fn country ->
      insert(:country_zone_member, zone: zone, country: country)
    end)
  end
end
