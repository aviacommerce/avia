defmodule SnitchApi.Review do
  @moduledoc false

  alias Snitch.Data.Model.Rating
  alias Snitch.Data.Model.{ProductReview, Review}
  alias Snitch.Core.Tools.MultiTenancy.Repo

  @review_attributes ["title", "description", "locale", "name", "user_id"]

  def create(%{"product_id" => product_id} = params) do
    attributes = parse_attribute_params(params)
    %{"rating_option_id" => option_id} = params

    case Rating.get_rating_option(option_id) do
      {:error, _} ->
        {:error, %{message: "rating_option_not_found"}}

      {:ok, rating_option} ->
        params = product_review_params(attributes, product_id, rating_option)
        ProductReview.add(params)
    end
  end

  def update(id, %{"rating_option_id" => rating_option_id} = params) do
    attributes = parse_attribute_params(params)

    case Rating.get_rating_option(rating_option_id) do
      {:error, _} ->
        {:error, %{message: "rating_option_not_found"}}

      {:ok, rating_option} ->
        params = Map.put(attributes, :rating_option_vote, %{rating_option: rating_option})
        update_review(id, params)
    end
  end

  def update(id, params) do
    attributes = parse_attribute_params(params)
    update_review(id, attributes)
  end

  def delete(%{"id" => id}) do
    Review.delete(String.to_integer(id))
  end

  defp update_review(id, params) do
    case Review.get(id) do
      nil ->
        {:error, :not_found}

      review ->
        review = Repo.preload(review, :rating_option_vote)
        Review.update(params, review)
    end
  end

  defp product_review_params(attributes, product_id, rating_option) do
    %{
      attributes: attributes,
      product_id: product_id,
      rating_option_vote: %{
        rating_option: rating_option
      }
    }
  end

  defp parse_attribute_params(params) do
    for {key, val} <- params, Enum.member?(@review_attributes, key), into: %{} do
      {String.to_atom(key), val}
    end
  end
end
