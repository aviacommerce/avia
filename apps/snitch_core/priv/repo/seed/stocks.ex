defmodule Snitch.Seed.Stocks do
  @moduledoc false

  import Ecto.Query

  alias Snitch.Repo
  alias Snitch.Data.Schema.{StockLocation, Variant, StockItem}
  alias Snitch.Data.Model.{State, Country}

  require Logger

  def seed_stock_locations! do
    locations =
      [
        %{
          name: "Statue of Liberty",
          admin_name: "default",
          default: true,
          address_line_1: "Liberty Island",
          address_line_2: "Manhattan",
          city: "New York",
          zip_code: "10004",
          phone: "(212) 363-3200",
          propagate_all_variants: false,
          active: true,
          state_id: State.get(%{code: "US-NY"}).id,
          country_id: Country.get(%{iso: "US"}).id
        },
        %{
          name: "Taj Mahal",
          admin_name: "backup",
          address_line_1: "Dharmapuri, Forest Colony",
          address_line_2: "Tajganj",
          city: "Agra",
          zip_code: "282001",
          phone: "+91-562-2227261",
          propagate_all_variants: false,
          active: true,
          state_id: State.get(%{code: "IN-UP"}).id,
          country_id: Country.get(%{iso: "IN"}).id
        },
        %{
          name: "Colosseum",
          admin_name: "origin",
          address_line_1: "Piazza del Colosseo, 1",
          address_line_2: "",
          city: "",
          zip_code: "00184",
          phone: "+39 06 3996 7700",
          propagate_all_variants: false,
          active: true,
          state_id: State.get(%{code: "IT-RM"}).id,
          country_id: Country.get(%{iso: "IT"}).id
        }
      ]
      |> Stream.map(&Map.put(&1, :inserted_at, Ecto.DateTime.utc()))
      |> Enum.map(&Map.put(&1, :updated_at, Ecto.DateTime.utc()))

    {count, _} = Repo.insert_all(StockLocation, locations, on_conflict: :nothing)
    Logger.info("Inserted #{count} stock_locations.")
  end

  def seed_stock_items!(digest_fn \\ &digest/1) do
    variants = Repo.all(Variant)

    query = from(sl in StockLocation, select: [:id, :admin_name])

    locations =
      query
      |> Repo.all()
      |> Enum.reduce(%{}, fn %{id: id, admin_name: nickname}, acc ->
        Map.put(acc, nickname, id)
      end)

    stock_items =
      variants
      |> digest_fn.()
      |> Enum.map(fn {location, manifest} ->
        Enum.map(manifest.variants, fn %{id: id} ->
          %{
            variant_id: id,
            stock_location_id: Map.fetch!(locations, location),
            count_on_hand: manifest.count_on_hand,
            backorderable: manifest.backorder,
            inserted_at: Ecto.DateTime.utc(),
            updated_at: Ecto.DateTime.utc()
          }
        end)
      end)
      |> List.flatten()

    {count, _} = Repo.insert_all(StockItem, stock_items, on_conflict: :nothing)
    Logger.info("Inserted #{count} stock_items.")
  end

  def digest(variants) do
    vc = Enum.count(variants)
    {one, two} = Enum.split(variants, div(vc, 2))

    %{
      "default" => %{
        count_on_hand: 4,
        variants: one,
        backorder: false
      },
      "backup" => %{
        count_on_hand: 6,
        variants: two,
        backorder: false
      },
      "origin" => %{
        count_on_hand: 2,
        variants: variants,
        backorder: true
      }
    }
  end
end
