defmodule AdminAppWeb.DataHelpers do
  @moduledoc """
  Provides view related data.
  """

  alias Snitch.Data.Model.State, as: StateModel
  alias Snitch.Data.Model.Country, as: CountryModel
  alias Snitch.Data.Model.Role, as: RoleModel

  @doc """
  Creates formatted data to be used in dropdown selection for association in forms.
  return => [{display name, value}, ...]
  passed to like => <%= select_input f, :country_id, formated_list(:country) %>
  Can also be used elsewhere.
  """
  def formatted_list(:state), do: StateModel.formatted_list()
  def formatted_list(:country), do: CountryModel.formatted_list()
  def formatted_list(:role), do: RoleModel.formatted_list()
end
