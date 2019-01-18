defmodule Snitch.Data.Model.Rating do
  @moduledoc """
  APIs for rating
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.{Rating, RatingOption}

  @doc """
  Returns all the ratings.
  """
  @spec get_all() :: [Rating.t()]
  def get_all do
    Repo.all(Rating)
  end

  @doc """
  Returns a `rating` by the supplied `id`.
  """
  @spec get(non_neg_integer) :: {:ok, Rating.t()} | {:error, atom}
  def get(id) do
    QH.get(Rating, id, Repo)
  end

  @spec get_rating_option(non_neg_integer) :: {:ok, RatingOption.t()} | {:error, atom}
  def get_rating_option(id) do
    QH.get(RatingOption, id, Repo)
  end
end
