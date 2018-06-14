defmodule Snitch.Domain.Zone do
  @moduledoc """
  Zone helpers.
  """

  use Snitch.Domain
  alias Snitch.Data.Model.{CountryZone, StateZone}

  @doc """
  Returns the state and country zone `struct`s that are common to both addresses
  in a tuple.

  Format: `{common_state_zones, common_country_zones}`
  """
  @spec common(region_map, region_map) :: {state_zones :: [Zone.t()], country_zones :: [Zone.t()]}
        when region_map: %{country_id: non_neg_integer}
  def common(%{country_id: a_c_id} = a, %{country_id: b_c_id} = b)
      when not (is_nil(a_c_id) or is_nil(b_c_id)) do
    {
      if is_nil(a.state_id) or is_nil(b.state_id) do
        []
      else
        Repo.all(StateZone.common_zone_query(a.state_id, b.state_id))
      end,
      Repo.all(CountryZone.common_zone_query(a.country_id, b.country_id))
    }
  end
end
