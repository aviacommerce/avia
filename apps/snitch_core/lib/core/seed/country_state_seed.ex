defmodule Snitch.Seed.CountryState do
  @moduledoc """
  This module has functions to create and insert seed data for the state and the country
  entitites.
  """

  import Ecto.Query
  alias Worldly.Country, as: WorldCountry
  alias Worldly.Region, as: WorldRegion
  alias Snitch.Repo
  alias Snitch.Data.Schema.Country

  def seed_countries_and_states! do
    insert_countries()
  end

  def insert_countries do
    uniq_countries = unique_countries()

    countries =
      WorldCountry.all()
      |> Enum.reject(&Map.get(uniq_countries, &1.name))

    insertable_countries =
      countries
      |> Enum.map(fn country -> to_param(country) end)

    {_, countries_ids} =
      Repo.insert_all(
        "snitch_countries",
        insertable_countries,
        on_conflict: :nothing,
        returning: [:id]
      )

    country_ids = Stream.map(countries_ids, fn x -> x.id end)

    countries
    |> Stream.map(&WorldRegion.regions_for/1)
    |> Stream.zip(country_ids)
    |> Enum.map(fn {statelist, id} ->
      Enum.map(statelist, fn state ->
        to_param(state, id)
      end)
    end)
    |> List.flatten()
    |> insert_and_map_states
  end

  def insert_and_map_states(states) do
    Repo.insert_all("snitch_states", states, on_conflict: :nothing)
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
      iso_name: String.upcase(name),
      inserted_at: Ecto.DateTime.utc(),
      updated_at: Ecto.DateTime.utc()
    }
  end

  defp to_param(%WorldRegion{code: abbr, name: name}, id) do
    %{
      abbr: to_string(abbr),
      name: to_string(name),
      country_id: id,
      inserted_at: Ecto.DateTime.utc(),
      updated_at: Ecto.DateTime.utc()
    }
  end

  defp unique_countries() do
    stream =
      Country
      |> select([c], {c.name, true})
      |> Repo.stream()

    {:ok, countries} = Repo.transaction(fn -> Enum.into(stream, %{}) end)
    countries
  end
end
