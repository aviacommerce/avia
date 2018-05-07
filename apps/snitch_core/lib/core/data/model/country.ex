defmodule Snitch.Data.Model.Country do
  @moduledoc """
  Country CRUD and helpers
  """

  use Snitch.Data.Model

  alias Snitch.Data.Schema.Country

  @spec get(map | non_neg_integer) :: Country.t() | nil
  def get(query_fields_or_primary_key) do
    QH.get(Country, query_fields_or_primary_key, Repo)
  end
end
