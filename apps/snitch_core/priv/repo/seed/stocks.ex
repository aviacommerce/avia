defmodule Snitch.Seed.Stocks do
  @moduledoc false

  alias Snitch.Data.Model.{Country, State}
  alias Snitch.Data.Schema.{StockItem, StockLocation, Variant}
  alias Snitch.Core.Tools.MultiTenancy.Repo

  require Logger

  @stock_items %{
    "origin" => %{
      counts: [10, 10, 10, 10, 00, 00],
      backorder: [:f, :f, :f, :f, :t, :t]
    },
    "warehouse" => %{
      counts: [00, 00, 8, 20, 10, 00],
      backorder: [:t, :f, :t, :f, :f, :f]
    }
  }

  def seed! do
    variants = Repo.all(Variant)

    Repo.transaction(fn ->
      locations =
        Enum.reduce(seed_stock_locations!(), %{}, fn %{id: id, name: name}, acc ->
          Map.put(acc, name, id)
        end)

      seed_stock_items!(variants, locations)
    end)
  end

  defp get_id({:ok, struct}) do
    struct.id
  end

  def seed_stock_locations! do
    states = %{
      state1: State.get(%{code: "US-NY"}) |> get_id,
      state2: State.get(%{code: "IN-UP"}) |> get_id,
      state3: State.get(%{code: "IT-RM"}) |> get_id,
      state4: State.get(%{code: "IN-MH"}) |> get_id
    }

    countries = %{
      country1: Country.get(%{iso: "US"}) |> get_id,
      country2: Country.get(%{iso: "IN"}) |> get_id,
      country3: Country.get(%{iso: "IT"}) |> get_id,
      country4: Country.get(%{iso: "IN"}) |> get_id
    }

    locations =
      [
        %{
          name: "Statue of Liberty",
          default: true,
          address_line_1: "Liberty Island",
          address_line_2: "Manhattan",
          city: "New York",
          zip_code: "10004",
          phone: "(212) 363-3200",
          propagate_all_variants: false,
          active: true,
          state_id: states.state1,
          country_id: countries.country1
        },
        %{
          name: "Taj Mahal",
          address_line_1: "Dharmapuri, Forest Colony",
          address_line_2: "Tajganj",
          city: "Agra",
          zip_code: "282001",
          phone: "+91-562-2227261",
          propagate_all_variants: false,
          active: true,
          state_id: states.state2,
          country_id: countries.country2
        },
        %{
          name: "Colosseum",
          address_line_1: "Piazza del Colosseo, 1",
          address_line_2: "",
          city: "",
          zip_code: "00184",
          phone: "+39 06 3996 7700",
          propagate_all_variants: false,
          active: true,
          state_id: states.state3,
          country_id: countries.country3
        },
        %{
          name: "Sinhagadh Fort",
          address_line_1: "Sinhagad Ghat Road",
          address_line_2: "Thoptewadi",
          city: "Pune",
          zip_code: "411025",
          phone: "020 2612 8169",
          propagate_all_variants: false,
          active: true,
          state_id: states.state4,
          country_id: countries.country4
        }
      ]
      |> Stream.map(&Map.put(&1, :inserted_at, DateTime.utc_now()))
      |> Enum.map(&Map.put(&1, :updated_at, DateTime.utc_now()))

    {count, locations} =
      Repo.insert_all(StockLocation, locations, on_conflict: :nothing, returning: true)

    Logger.info("Inserted #{count} stock_locations.")
    locations
  end

  def seed_stock_items!(variants, locations) when map_size(locations) > 0 do
    stock_items =
      @stock_items
      |> Enum.map(fn {location, manifest} ->
        [variants, manifest.counts, manifest.backorder]
        |> Enum.zip()
        |> Enum.map(fn {%{id: id}, count, backorder} ->
          %{
            product_id: id,
            stock_location_id: Map.fetch!(locations, location),
            count_on_hand: count,
            backorderable: if(backorder == :t, do: true, else: false),
            inserted_at: DateTime.utc_now(),
            updated_at: DateTime.utc_now()
          }
        end)
      end)
      |> List.flatten()

    {count, _} = Repo.insert_all(StockItem, stock_items, on_conflict: :nothing)
    Logger.info("Inserted #{count} stock_items.")
  end

  def seed_stock_items!(_, _) do
    Logger.info("Inserted 0 stock_items.")
  end
end
