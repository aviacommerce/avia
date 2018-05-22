defmodule AdminAppWeb.DataHelpers do
  @moduledoc """
  Provides view related data.
  """

  alias Snitch.Data.Model.State, as: StateModel
  alias Snitch.Data.Model.Country, as: CountryModel

  @doc """
  Creates formatted data to be used in dropdown selection for association in forms.
  return => [{display name, value}, ...]
  passed to like => <%= select_input f, :country_id, formated_list(:country) %>
  Can also be used elsewhere.
  """
  def formated_list(:state), do: StateModel.formated_list()
  def formated_list(:country), do: CountryModel.formated_list()
end
