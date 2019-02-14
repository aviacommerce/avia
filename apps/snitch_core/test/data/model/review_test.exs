defmodule Snitch.Data.Model.ReviewTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory
  alias Snitch.Data.Model.{Review, ProductReview}

  setup :rating_options
  setup :review_params

  describe "update/2" do
    test "updates a review successfully", %{
      review: review,
      rating_option_vote: rating_option_vote
    } do
      update_params = %{
        description: "new description",
        rating_option_vote: rating_option_vote
      }

      {:ok, updated_review} = Review.update(update_params, review)
      assert updated_review.id == review.id
      assert updated_review.description != review.description
    end

    test "fails for invalid params", %{review: review} do
      update_params = %{description: ""}

      {:error, updated_review} = Review.update(update_params, review)
      assert %{description: ["can't be blank"]} == errors_on(updated_review)
    end
  end

  describe "delete/1" do
    test "successful for valid id", %{review: review} do
      assert {:ok, _} = Review.delete(review.id)
      assert Review.get(review.id) == {:error, :review_not_found}
    end

    test "fails for invalid id" do
      {:error, :review_not_found} = Review.get(-1)
    end
  end

  describe "get/1" do
    test "returns a review", %{review: review} do
      {:ok, new_review} = Review.get(review.id)
      assert new_review.id == review.id
    end

    test "fails for invalid id" do
      {:error, :review_not_found} = Review.get(-1)
    end
  end

  defp review_params(context) do
    %{rating_options: rating_options} = context
    [rating_option_1, rating_option_2] = rating_options

    review = insert(:review, rating_option_vote: %{rating_option: rating_option_1})
    rating_option_vote = %{rating_option: rating_option_2}
    %{review: review, rating_option_vote: rating_option_vote}
  end
end
