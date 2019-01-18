defmodule Snitch.Data.Model.Country do
  @moduledoc """
  Country CRUD and helpers
  """

  use Snitch.Data.Model

  alias Snitch.Data.Schema.Country

  @spec get(map | non_neg_integer) :: {:ok, Country.t()} | {:error, atom}
  def get(query_fields_or_primary_key) do
    QH.get(Country, query_fields_or_primary_key, Repo)
  end

  @spec get_all() :: [Country.t()]
  def get_all() do
    Repo.all(Country)
  end

  @spec formatted_list() :: [{String.t(), non_neg_integer}]
  def formatted_list do
    Country
    |> order_by([s], asc: s.name)
    |> select([s], {s.name, s.id})
    |> Repo.all()
  end
end
