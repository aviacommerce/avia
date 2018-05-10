defmodule Snitch.Data.Schema.CountryZoneMemberTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.CountryZoneMember

  setup :countries

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
end
