defmodule AdminAppWeb.DataHelpers do
  @moduledoc """
  Provides view related data.
  """

  alias Snitch.Data.Model.State, as: StateModel
  alias Snitch.Data.Model.Country, as: CountryModel
  alias Snitch.Data.Model.Role, as: RoleModel
  alias Snitch.Data.Model.TaxClass
  alias Snitch.Data.Model.Permission
  alias Snitch.Data.Model.Zone

  @doc """
  Creates formatted data to be used in dropdown selection for association in forms.
  return => [{display name, value}, ...]
  passed to like => <%= select_input f, :country_id, formated_list(:country) %>
  Can also be used elsewhere.
  """
  def formatted_list(:state), do: StateModel.formatted_list()
  def formatted_list(:country), do: CountryModel.formatted_list()
  def formatted_list(:role), do: RoleModel.formatted_list()
  def formatted_list(:permissions), do: Permission.formatted_list()
  def formatted_list(:tax_class), do: TaxClass.formatted_list()
  def formatted_list(:zone), do: Zone.formatted_list()
  def formatted_list(country_id), do: StateModel.formatted_state_list(country_id)
end
