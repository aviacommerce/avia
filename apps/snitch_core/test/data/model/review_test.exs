defmodule Snitch.Data.Model.ReviewTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory
  alias Snitch.Data.Model.{Review, ProductReview}

  setup :reviews

  @tag review_count: 2
  describe "update/2" do
    test "updates a review successfully", %{reviews: reviews} do
      [review, review_2] = reviews
      rpv = review_2.rating_option_vote
      rating_option_vote = Map.from_struct(rpv)

      update_params = %{
        description: "new description",
        rating_option_vote: rating_option_vote
      }

      assert {:ok, updated_review} = Review.update(update_params, review)
      assert updated_review.id == review.id
      assert updated_review.description != review.description
    end

    test "fails for invalid params", %{reviews: [review]} do
      update_params = %{description: ""}

      {:error, updated_review} = Review.update(update_params, review)
      assert %{description: ["can't be blank"]} == errors_on(updated_review)
    end
  end

  describe "delete/1" do
    test "successful for valid id", %{reviews: [review]} do
      assert {:ok, _} = Review.delete(review.id)
      assert Review.get(review.id) == {:error, :review_not_found}
    end

    test "fails for invalid id" do
      {:error, :review_not_found} = Review.get(-1)
    end
  end

  describe "get/1" do
    test "returns a review", %{reviews: [review]} do
      {:ok, new_review} = Review.get(review.id)
      assert new_review.id == review.id
    end

    test "fails for invalid id" do
      {:error, :review_not_found} = Review.get(-1)
    end
  end
end
