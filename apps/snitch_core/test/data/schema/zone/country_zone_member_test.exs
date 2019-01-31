defmodule Snitch.Data.Schema.CountryZoneMemberTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.CountryZoneMember

  setup :countries

  describe "create_changeset/2" do
    test "successfully for valid params", %{countries: [country]} do
      zone = insert(:zone, zone_type: "C")
      params = %{zone_id: zone.id, country_id: country.id}
      cs = CountryZoneMember.create_changeset(%CountryZoneMember{}, params)
      assert cs.valid?
    end

    test "fails for invalid params" do
      params = %{zone_id: nil, country_id: nil}
      cs = CountryZoneMember.create_changeset(%CountryZoneMember{}, params)
      assert %{zone_id: ["can't be blank"], country_id: ["can't be blank"]} == errors_on(cs)
    end
  end

  describe "CountryZoneMember records" do
    test "refer only country type zones", %{countries: [country]} do
      country_zone = insert(:zone, zone_type: "C")

      new_country_zone =
        CountryZoneMember.create_changeset(%CountryZoneMember{country_id: country.id}, %{
          zone_id: country_zone.id
        })

      assert {:ok, _} = Repo.insert(new_country_zone)
    end

    test "don't refer a state zone", %{countries: [country]} do
      state_zone = insert(:zone, zone_type: "S")

      new_country_zone =
        CountryZoneMember.create_changeset(%CountryZoneMember{country_id: country.id}, %{
          zone_id: state_zone.id
        })

      assert {:error, %Ecto.Changeset{errors: errors}} = Repo.insert(new_country_zone)
      assert errors == [zone_id: {"does not refer a country zone", []}]
    end

    test "don't allow duplicate countries in a given zone", %{countries: [country]} do
      country_zone = insert(:zone, zone_type: "C")

      czm_changset =
        CountryZoneMember.create_changeset(%CountryZoneMember{country_id: country.id}, %{
          zone_id: country_zone.id
        })

      assert {:ok, _} = Repo.insert(czm_changset)
      assert {:error, cs} = Repo.insert(czm_changset)
      assert %{country_id: ["has already been taken"]} = errors_on(cs)
    end
  end

  describe "update_changeset/2" do
    setup %{countries: [country]} do
      zone = insert(:zone, zone_type: "C")
      params = %{zone_id: zone.id, country_id: country.id}

      [
        cs:
          %CountryZoneMember{}
          |> CountryZoneMember.create_changeset(params)
          |> apply_changes()
      ]
    end

    test "returns a valid changeset", %{cs: cs} do
      params = %{country_id: 200}
      changeset = CountryZoneMember.update_changeset(cs, params)
      assert changeset.valid?
    end

    test "fails for invalid params", %{cs: cs} do
      params = %{country_id: -1}
      changeset = CountryZoneMember.update_changeset(cs, params)
      {:error, changeset} = Repo.insert(changeset)
      assert %{country_id: ["does not exist"]} == errors_on(changeset)
    end

    test "fails for duplicate country_id", %{cs: cs} do
      Repo.insert(cs)
      params = %{country_id: cs.country_id}
      changeset = CountryZoneMember.update_changeset(cs, params)
      {:error, cs} = Repo.insert(changeset)
      assert %{country_id: ["has already been taken"]} = errors_on(cs)
    end
  end
end
