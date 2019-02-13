defmodule Snitch.Data.Schema.ReviewTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.Review

  setup :review_params

  describe "create_changeset/2" do
    test "returns a valid changeset", %{params: params} do
      changeset = Review.create_changeset(%Review{}, params)
      assert changeset.valid?
    end

    test "returns invalid changeset" do
      changeset = Review.create_changeset(%Review{}, %{})

      assert %{
               rating_option_vote: ["can't be blank"],
               description: ["can't be blank"],
               user_id: ["can't be blank"],
               name: ["can't be blank"]
             } == errors_on(changeset)
    end

    test "fails for non-existent user_id", %{params: params} do
      params = %{params | user_id: -1}
      cs = Review.create_changeset(%Review{}, params)
      {:error, changeset} = Repo.insert(cs)
      assert %{user_id: ["does not exist"]} == errors_on(changeset)
    end
  end

  describe "update_changeset/2" do
    test "returns a valid changeset", %{review: review} do
      params = %{description: "hakuna matata"}
      cs = Review.update_changeset(review, params)
      assert cs.valid?
    end

    test "fails for invalid params", %{review: review} do
      params = %{description: ""}
      cs = Review.update_changeset(review, params)
      assert %{description: ["can't be blank"]} == errors_on(cs)
    end
  end

  defp review_params(context) do
    review = insert(:review)
    rating_option_vote = review.rating_option_vote
    rating_option_vote = Map.from_struct(rating_option_vote)

    params = %{
      description: "awesomeness redefined",
      name: "stark",
      user_id: review.user_id,
      rating_option_vote: rating_option_vote
    }

    [params: params, review: review]
  end
end
