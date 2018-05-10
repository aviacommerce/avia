defmodule Snitch.Data.Schema.CountryTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  alias Snitch.Data.Schema.Country

  @valid_attrs %{
    iso_name: "INDIA",
    iso: "IN",
    iso3: "IND",
    name: "India",
    numcode: "356"
  }

  @db_attrs %Country{
    iso_name: "INDIA",
    iso: "IN",
    iso3: "IND",
    name: "India",
    numcode: "356"
  }

  describe "Countries" do
    test "with valid attributes" do
      %{valid?: validity} = Country.changeset(%Country{}, @valid_attrs)
      assert validity
    end

    test "with invalid attributes" do
      params = Map.delete(@valid_attrs, :numcode)
      %{valid?: validity} = Country.changeset(%Country{}, params)
      refute validity
    end

    test "with invalid iso" do
      params = Map.put(@valid_attrs, :iso, "IND")
      c_changeset = %{valid?: validity} = Country.changeset(%Country{}, params)
      refute validity
      assert %{iso: ["should be 2 character(s)"]} = errors_on(c_changeset)
    end

    test "with invalid iso3" do
      params = Map.put(@valid_attrs, :iso3, "INDI")
      c_changeset = %{valid?: validity} = Country.changeset(%Country{}, params)
      refute validity
      assert %{iso3: ["should be 3 character(s)"]} = errors_on(c_changeset)
    end

    test "with duplicate iso" do
      Repo.insert!(@db_attrs)

      changeset = Country.changeset(%Country{}, @valid_attrs)

      {:error, changeset} = Repo.insert(changeset)
      assert [iso: {"has already been taken", []}] = changeset.errors
    end

    test "with duplicate iso3" do
      Repo.insert!(@db_attrs)

      changeset =
        Country.changeset(%Country{}, %{
          iso_name: "JAPAN",
          iso: "JP",
          iso3: "IND",
          name: "Japan",
          numcode: "392"
        })

      {:error, changeset} = Repo.insert(changeset)
      assert [iso3: {"has already been taken", []}] = changeset.errors
    end

    test "with duplicate name" do
      Repo.insert!(@db_attrs)

      changeset =
        Country.changeset(%Country{}, %{
          iso_name: "JAPAN",
          iso: "JP",
          iso3: "JPN",
          name: "India",
          numcode: "392"
        })

      {:error, changeset} = Repo.insert(changeset)
      assert [name: {"has already been taken", []}] = changeset.errors
    end

    test "with duplicate numcode" do
      Repo.insert!(@db_attrs)

      changeset =
        Country.changeset(%Country{}, %{
          iso_name: "JAPAN",
          iso: "JP",
          iso3: "JPN",
          name: "Japan",
          numcode: "356"
        })

      {:error, changeset} = Repo.insert(changeset)
      assert [numcode: {"has already been taken", []}] = changeset.errors
    end

    test "with all empty" do
      c_changeset = %{valid?: validity} = Country.changeset(%Country{}, %{})
      refute validity
      assert %{name: ["can't be blank"]} = errors_on(c_changeset)
    end
  end
end
