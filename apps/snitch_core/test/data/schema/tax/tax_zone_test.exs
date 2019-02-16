defmodule Snitch.Data.Schema.TaxZoneTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Schema.TaxZone

  describe "create_changeset/2" do
    test "fails for missing params" do
      params = %{}
      changeset = TaxZone.create_changeset(%TaxZone{}, params)

      assert %{name: ["can't be blank"], zone_id: ["can't be blank"]} == errors_on(changeset)
    end

    test "fails with invalid zone_id" do
      params = %{zone_id: -1, name: "India"}
      changeset = TaxZone.create_changeset(%TaxZone{}, params)

      assert {:error, changeset} = Repo.insert(changeset)
      assert %{zone_id: ["does not exist"]} == errors_on(changeset)
    end

    test "fails for unique constraitnts" do
      zone = insert(:zone, zone_type: "S")
      tax_zone = insert(:tax_zone, zone: zone, is_default: true)

      params = %{name: "AAPCTax", zone_id: zone.id}
      changeset = TaxZone.create_changeset(%TaxZone{}, params)

      {:error, changeset} = Repo.insert(changeset)
      assert %{zone_id: ["tax zone exists with supplied zone"]} == errors_on(changeset)

      zone_new = insert(:zone, zone_type: "C")
      params = %{name: tax_zone.name, zone_id: zone_new.id}
      changeset = TaxZone.create_changeset(%TaxZone{}, params)

      {:error, changeset} = Repo.insert(changeset)

      assert %{name: ["has already been taken"]} == errors_on(changeset)

      params = %{name: "EUVAT", is_default: true, zone_id: zone_new.id}
      changeset = TaxZone.create_changeset(%TaxZone{}, params)

      {:error, changeset} = Repo.insert(changeset)
      assert %{is_default: ["unique default tax zone"]} == errors_on(changeset)
    end
  end
end
