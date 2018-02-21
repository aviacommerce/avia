defmodule Core.Seed.CountryStateSeeder do
  @moduledoc """
  This module has functions to create and insert seed data for the state and the country
  entitites.
  """

  alias Worldly.Country, as: WorldCountry
  alias Worldly.Region, as: WorldRegion
  alias Core.Snitch.{Country}
  alias Core.Repo

  def seed_countries_and_states! do
    Enum.each(WorldCountry.all(), fn country -> seed_country_data(country) end)
  end

  def seed_country_data(country) do
    change = Country.changeset(%Country{}, to_param(country))
    inserted_country = Repo.insert!(change)

    if country.has_regions do
      Enum.each(WorldRegion.regions_for(country), fn region ->
        seed_state_data(inserted_country, region)
      end)
    end
  end

  def seed_state_data(country, state) do
    country
    |> Ecto.build_assoc(:snitch_states, to_param(state))
    |> Repo.insert!()
  end

  defp to_param(%WorldCountry{
         name: name,
         alpha_2_code: iso,
         alpha_3_code: iso3,
         numeric_code: numcode,
         has_regions: has_regions
       }) do
    %{
      name: name,
      iso: iso,
      iso3: iso3,
      numcode: numcode,
      states_required: has_regions,
      iso_name: String.upcase(name)
    }
  end

  defp to_param(%WorldRegion{code: abbr, name: name}) do
    %{abbr: to_string(abbr), name: to_string(name)}
  end
end
