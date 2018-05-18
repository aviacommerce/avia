defmodule Snitch.Data.Model.State do
  @moduledoc """
  State CRUD and helpers
  """

  use Snitch.Data.Model

  alias Snitch.Data.Schema.State

  @spec get(map | non_neg_integer) :: State.t() | nil
  def get(query_fields_or_primary_key) do
    QH.get(State, query_fields_or_primary_key, Repo)
  end

  @spec formatted_list() :: [{String.t(), non_neg_integer}]
  def formatted_list, do: Repo.all(from(s in State, select: {s.name, s.id}))
end
