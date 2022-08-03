defmodule Snitch.Seed.CountryState do
  @moduledoc false

  import Ecto.Query

  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Schema.Country, as: CountrySchema
  alias Snitch.Data.Schema.State, as: StateSchema
  alias ExRegion.{Country, Subdivision}

  require Logger

  def seed_countries!() do
    countries = Enum.map(Country.fetch_all(), &to_country_params/1)
    {count, _} = Repo.insert_all(CountrySchema, countries, on_conflict: :nothing)
    Logger.info("Inserted #{count} countries.")
  end

  def seed_states!() do
    query = from(CountrySchema, select: [:id, :iso])

    countries =
      query
      |> Repo.all()
      |> Enum.reduce(%{}, fn %{id: id, iso: iso}, acc ->
        Map.put(acc, iso, id)
      end)

    iso_subdivs = Subdivision.fetch_all()

    subdivs =
      iso_subdivs
      |> Stream.map(fn sub ->
        id = Map.fetch!(countries, sub.country)
        Map.put(sub, :country_id, id)
      end)
      |> Enum.map(&to_state_params/1)

    {count, _} = Repo.insert_all(StateSchema, subdivs, on_conflict: :nothing)
    Logger.info("Inserted #{count} subdivisions.")

    countries_with_subdivs =
      iso_subdivs
      |> Subdivision.group_by_country()
      |> Map.keys()
      |> Enum.map(&Map.fetch!(countries, &1))

    query = from(c in CountrySchema, where: c.id in ^countries_with_subdivs)
    {count, _} = Repo.update_all(query, set: [states_required: true])

    Logger.info("#{count} countries have subdivisions.")
  end

  def to_country_params(country) do
    %{
      iso_name: country.name,
      iso: country.alpha_2,
      iso3: country.alpha_3,
      name: country.name,
      numcode: country.numeric,
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }
  end

  def to_state_params(%{
        name: name,
        code: code,
        country_id: country_id
      }) do
    %{
      name: name,
      code: code,
      country_id: country_id,
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }
  end
end
