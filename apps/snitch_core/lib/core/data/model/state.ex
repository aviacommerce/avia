defmodule Snitch.Data.Model.State do
  @moduledoc """
  State CRUD and helpers
  """

  use Snitch.Data.Model

  alias Snitch.Data.Schema.State

  @spec get(map | non_neg_integer) :: {:ok, State.t()} | {:error, atom}
  def get(query_fields_or_primary_key) do
    QH.get(State, query_fields_or_primary_key, Repo)
  end

  @spec get_all() :: [State.t()]
  def get_all() do
    Repo.all(State)
  end

  @spec formatted_list() :: [{String.t(), non_neg_integer}]
  def formatted_list do
    State
    |> order_by([s], asc: s.name)
    |> select([s], {s.name, s.id})
    |> Repo.all()
  end

  @spec formatted_state_list(integer) :: [{String.t(), non_neg_integer}]
  def formatted_state_list(country_id) do
    State
    |> where([s], s.country_id == ^country_id)
    |> order_by([s], asc: s.name)
    |> select([s], %{text: s.name, id: s.id})
    |> Repo.all()
  end
end
