defmodule Snitch.Data.Model.ProductReviewTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model.ProductReview

  setup do
    product = insert(:product)
    [product: product]
  end

  setup :rating_options

  @tag rating_option_count: 1
  test "create product review successfully", context do
    %{product: product} = context
    user = insert(:user)
    %{rating_options: rating_options} = context
    rating_option = List.first(rating_options)
    review_params = product_review_params(product, user, rating_option)
    assert {:ok, _} = ProductReview.add(review_params)
    product = Repo.preload(product, :reviews)
    assert length(product.reviews) != 0
  end

  @tag rating_option_count: 1
  test "creation fails for invalid params", context do
    %{product: product} = context
    user = %{id: -1}
    %{rating_options: rating_options} = context
    rating_option = List.first(rating_options)
    review_params = product_review_params(product, user, rating_option)
    assert {:error, changeset} = ProductReview.add(review_params)
    assert %{user_id: ["does not exist"]} = errors_on(changeset)
  end

  @tag rating_option_count: 2
  test "get rating aggregate for a product", context do
    %{product: product} = context
    user1 = insert(:user)
    user2 = insert(:user, role: %{name: "user"})
    %{rating_options: rating_options} = context

    [rating_option_1 | [rating_option_2 | _]] = rating_options
    review_params = product_review_params(product, user1, rating_option_1)
    assert {:ok, _} = ProductReview.add(review_params)
    review_params = product_review_params(product, user2, rating_option_2)
    assert {:ok, _} = ProductReview.add(review_params)
    result = ProductReview.review_aggregate(product)

    assert result.average_rating ==
             Decimal.div(rating_option_1.value + rating_option_2.value, 2)
             |> Decimal.round(1)

    assert result.review_count == 2
  end

  @tag rating_option_count: 2
  describe "fetch_rating_option/1" do
    test "return a valid rating_option", context do
      %{rating_options: rating_options} = context
      [rating_option_1 | rating_option_2] = rating_options
      {:ok, returned_rating_option} = ProductReview.fetch_rating_option(rating_option_1.id)
      assert returned_rating_option.id == rating_option_1.id
    end

    test "fails for invalid id" do
      assert {:error, :rating_option_not_found} = ProductReview.fetch_rating_option(-1)
    end
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
