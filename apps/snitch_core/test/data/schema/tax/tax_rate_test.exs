defmodule Snitch.Data.Schema.TaxRateTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Schema.TaxRate

  describe "create_changeset/2" do
    test "returns invalid changeset for missing params" do
      params = %{}
      changeset = TaxRate.create_changeset(%TaxRate{}, params)
      refute changeset.valid?

      assert %{
               name: ["can't be blank"],
               tax_rate_class_values: ["can't be blank"],
               tax_zone_id: ["can't be blank"]
             } == errors_on(changeset)
    end

    test "return valid changeset" do
      tax_class_1 = insert(:tax_class)
      tax_class_2 = insert(:tax_class)

      tax_class_values = [
        %{tax_class_id: tax_class_1.id, percent_amount: 2},
        %{tax_class_id: tax_class_2.id, percent_amount: 3}
      ]

      tax_zone = setup_tax_zone()

      params = %{name: "GST", tax_rate_class_values: tax_class_values, tax_zone_id: tax_zone.id}
      changeset = TaxRate.create_changeset(%TaxRate{}, params)
      assert changeset.valid?
    end

    test "fails for invalid tax-zone id" do
      tax_class_1 = insert(:tax_class)
      tax_class_2 = insert(:tax_class)

      tax_class_values = [
        %{tax_class_id: tax_class_1.id, percent_amount: 2},
        %{tax_class_id: tax_class_2.id, percent_amount: 3}
      ]

      params = %{name: "GST", tax_rate_class_values: tax_class_values, tax_zone_id: -1}

      changeset = TaxRate.create_changeset(%TaxRate{}, params)
      assert {:error, changeset} = Repo.insert(changeset)
      assert %{tax_zone_id: ["does not exist"]} = errors_on(changeset)
    end
  end

  describe "update_changeset/2" do
    test "returns a valid changeset" do
      tax_zone = setup_tax_zone()
      tax_rate = :tax_rate |> insert(tax_zone: tax_zone) |> Repo.preload(:tax_rate_class_values)

      tax_class_1 = insert(:tax_class)
      tax_class_2 = insert(:tax_class)

      tax_class_values = [
        %{tax_class_id: tax_class_1.id, percent_amount: 2},
        %{tax_class_id: tax_class_2.id, percent_amount: 3}
      ]

      params = %{tax_rate_class_values: tax_class_values}

      changeset = TaxRate.update_changeset(tax_rate, params)
      assert changeset.valid?
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
