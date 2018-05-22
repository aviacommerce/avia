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
end
