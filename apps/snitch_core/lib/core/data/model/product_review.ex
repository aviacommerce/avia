defmodule Snitch.Data.Model.ProductReview do
  @moduledoc """
  API functions ProductReview.
  """

  alias Ecto.Multi
  use Snitch.Data.Model
  alias Snitch.Data.Schema.ProductReview
  alias Snitch.Data.Schema.RatingOption
  alias Snitch.Data.Schema.Review

  @review_detail %{
    average_rating: Decimal.new(0),
    review_count: 0,
    rating_summary: []
  }

  @doc """
  Creates a product review with the supplied params.

  To create a product review the `params` should include
  `review_attributes` under the `:attributes` key.
  ## See
  `Review`

  Also the `rating_option` `struct` should be provided under the
  `:rating_option_vote` key in the `params`.
  ## See
  `Rating`
  `RatingOption`

  The `id` of the `product` for which review should be created
  should be passed under the `:product_id` key in `params`.
  """

  @spec add(map) ::
          {:ok, Review.t()}
          | {:error, Ecto.Changeset.t()}
  def add(params) do
    Multi.new()
    |> Multi.run(:review, fn _ ->
      params = parse_review_params(params)
      QH.create(Review, params, Repo)
    end)
    |> Multi.run(:associate_product, fn %{review: review} ->
      %{product_id: product_id} = params
      params = %{product_id: product_id, review_id: review.id}
      QH.create(ProductReview, params, Repo)
    end)
    |> persist()
  end

  ## TODO To be replaced with a record in database.
  @doc """
  Returns the average rating, review_count and rating details for
  a product.

  The structure returned is a map of following signature:
  %{
    average_rating: 3.5 #average rating for the product
    review_count: 10 # number of reviews for a product
    rating_detail: [
      value_1: # values are rating_option codes corresponding to
                "product" rating
      value_2:
      value_n:
    ]
  }

  ## See
  `RatingOption`
  """
  @spec review_aggregate(Product.t()) :: map
  def review_aggregate(product) do
    reviews =
      product
      |> Repo.preload(reviews: [rating_option_vote: :rating_option])
      |> Map.get(:reviews)

    calculate_aggregate(reviews, length(reviews), @review_detail)
  end

  ################## private functions #################

  defp calculate_aggregate(_, 0, review_detail) do
    review_detail
  end

  defp calculate_aggregate(reviews, count, review_detail) do
    {rating_detail, sum} =
      Enum.reduce(reviews, {review_detail.rating_summary, 0}, fn review,
                                                                 {rating_detail_list, rating_sum} ->
        code = String.to_atom(review.rating_option_vote.rating_option.code)
        position = review.rating_option_vote.rating_option.position
        rating_value = get_rating_value(Keyword.get(rating_detail_list, code)) || 0
        rating_value = rating_value + 1
        params = %{value: rating_value, position: position}
        rating_detail_list = Keyword.put(rating_detail_list, code, params)
        {rating_detail_list, review.rating_option_vote.rating_option.value + rating_sum}
      end)

    rating_percent_list =
      Enum.map(rating_detail, fn {code, params} ->
        {code, %{params | value: params.value / count * 100}}
      end)

    %{
      review_detail
      | average_rating: sum |> Decimal.div(count) |> Decimal.round(1),
        review_count: count,
        rating_summary: rating_percent_list
    }
  end

  defp get_rating_value(nil), do: nil
  defp get_rating_value(rating_data), do: Map.get(rating_data, :value)

  defp parse_review_params(params) do
    %{attributes: review_params} = params
    %{rating_option_vote: %{rating_option: rating_option}} = params
    Map.put(review_params, :rating_option_vote, %{rating_option: rating_option})
  end

  def fetch_rating_option(id) do
    QH.get(RatingOption, id, Repo)
  end

  def persist(multi) do
    case Repo.transaction(multi) do
      {:ok, %{review: review}} ->
        {:ok, review}

      {:error, _, error_value, _} ->
        {:error, error_value}
    end
  end
end
