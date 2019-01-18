defmodule Snitch.Data.Model.Review do
  @moduledoc """
  APIs for Review.
  """
  use Snitch.Data.Model
  alias Snitch.Data.Schema.Review

  @doc """
  Udpates a `review` with supplied `params`.

  To update the `rating_option_vote` this `review`
  has, a `rating_option` struct is expected under the
  `:rating_option` key nested inside the `review_option_vote`
  key.

  ## Example
    params = %{
      description: "modified from earlier"
      rating_option_vote: %{
        rating_option: %RatingOption{
          code: "1", position: 1, value: 1
        }
      }
    }
  """

  @spec update(map, Review.t()) ::
          {:ok, Review.t()}
          | {:error, Ecto.Changeset.t()}
  def update(params, review) do
    QH.update(Review, params, review, Repo)
  end

  @doc """
  Deletes a `review` for supplied `id`.
  """
  @spec delete(Review.t()) ::
          {:ok, Review.t()}
          | {:error, Ecto.Changeset.t()}
  def delete(id) do
    QH.delete(Review, id, Repo)
  end

  @doc """
  Returns a review for the supplied `id`
  """
  @spec get(non_neg_integer) :: {:ok, Review.t()} | {:error, atom}
  def get(id) do
    QH.get(Review, id, Repo)
  end
end
