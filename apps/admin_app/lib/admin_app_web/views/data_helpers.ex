defmodule AdminAppWeb.DataHelpers do
  @moduledoc """
  Provides view related data.
  """

  alias Snitch.Data.Model.State, as: StateModel
  alias Snitch.Data.Model.Country, as: CountryModel
  alias Snitch.Data.Model.StockLocation, as: SLModel
  alias Snitch.Data.Model.ReturnAuthorizationReason, as: RARModel

  @doc """
  Creates formatted data to be used in dropdown selection for association in forms.
  return => [{display name, value}, ...]
  passed to like => <%= select_input f, :country_id, formated_list(:country) %>
  Can also be used elsewhere.
  """
  def formatted_list(:state), do: StateModel.formatted_list()
  def formatted_list(:country), do: CountryModel.formatted_list()
  def formatted_list(:stock_location), do: SLModel.formatted_list()
  def formatted_list(:return_reasons), do: RARModel.formatted_list()
end
