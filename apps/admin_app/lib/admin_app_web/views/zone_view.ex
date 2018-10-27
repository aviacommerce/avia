defmodule AdminAppWeb.ZoneView do
  use AdminAppWeb, :view

  alias Snitch.Data.Model.{State, Country, Zone}
  alias Snitch.Data.Schema.Zone, as: ZoneSchema
  alias Snitch.Core.Tools.MultiTenancy.Repo

  def get_zones() do
    [Country: "C", State: "S"]
  end

  def get_states() do
    State.formatted_list()
  end

  def get_countries() do
    Country.formatted_list()
  end

  def get_zone_by_type(zone) do
    case zone.zone_type do
      "C" -> "Country"
      "S" -> "State"
    end
  end

  def get_zone(zone_id) do
    Zone.get(zone_id)
  end

  def get_zone_members(zone) do
    zone |> Zone.members() |> Enum.into([], fn x -> x.id end)
  end

  def get_list(type) do
    case type do
      "C" -> get_countries()
      _ -> get_states()
    end
  end

  def get_zone_type_name(type) do
    case type do
      "C" -> "Country"
      "S" -> "State"
    end
  end

  def check_min_zones() do
    length(Repo.all(ZoneSchema)) > 1
  end
end
