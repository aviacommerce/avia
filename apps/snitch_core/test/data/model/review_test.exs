defmodule Snitch.Data.Model.ReviewTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory
  alias Snitch.Data.Model.{Review, ProductReview}

  setup do
    product = insert(:product)
    [product: product]
  end

  setup :rating_options

  @tag rating_option_count: 2
  test "update a review successfully", context do
    %{product: product} = context
    user = insert(:user)
    %{rating_options: rating_options} = context
    [rating_option_1 | [rating_option_2 | _]] = rating_options
    review_params = product_review_params(product, user, rating_option_1)
    assert {:ok, review} = ProductReview.add(review_params)

    update_params = %{
      description: "new description",
      rating_option_vote: %{rating_option: rating_option_2}
    }

    assert {:ok, updated_review} = Review.update(update_params, review)
    assert updated_review.id == review.id
    assert updated_review.description != review.description
  end

  @tag rating_option_count: 1
  test "delete a product review", context do
    %{product: product} = context
    user = insert(:user)
    %{rating_options: rating_options} = context
    rating_option = List.first(rating_options)
    review_params = product_review_params(product, user, rating_option)
    assert {:ok, review} = ProductReview.add(review_params)
    product_before_delete = Repo.preload(product, :reviews)
    assert length(product_before_delete.reviews) != 0
    assert {:ok, _} = Review.delete(review.id)
    product_after_delete = Repo.preload(product, :reviews)
    assert product_after_delete.reviews == []
  end

  defp product_review_params(product, user, rating_option) do
    %{
      attributes: %{
        description: "awesomeness redefined",
        user_id: user.id,
        name: "stark"
      },
      rating_option_vote: %{
        rating_option: rating_option
      },
      product_id: product.id
    }
  end
end
