defmodule Snitch.Data.Schema.ProductReviewTest do
  use ExUnit.Case
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.ProductReview

  setup do
    product_review = insert(:product_review)
    [product_review: product_review]
  end

  describe "create_changeset/2" do
    test "returns a valid changeset", %{product_review: product_review} do
      params = Map.from_struct(product_review)
      changeset = ProductReview.create_changeset(%ProductReview{}, params)
      assert changeset.valid?
    end

    test "fails for invalid params" do
      changeset = ProductReview.create_changeset(%ProductReview{}, %{})

      assert %{product_id: ["can't be blank"], review_id: ["can't be blank"]} ==
               errors_on(changeset)
    end

    test "fails for non-existent product_id and review_id", %{product_review: product_review} do
      product_review_1 = %{product_review | product_id: -1}
      params = Map.from_struct(product_review_1)
      cs = ProductReview.create_changeset(%ProductReview{}, params)
      {:error, changeset} = Repo.insert(cs)
      assert %{product_id: ["does not exist"]} == errors_on(changeset)

      product_review = %{product_review | product_id: product_review.product_id, review_id: -1}
      params = Map.from_struct(product_review)
      cs = ProductReview.create_changeset(%ProductReview{}, params)
      {:error, changeset} = Repo.insert(cs)
      assert %{review_id: ["does not exist"]} == errors_on(changeset)
    end
  end

  describe "update_changeset/2" do
    test "returns a valid changeset", %{product_review: product_review} do
      params = %{review_id: 20}
      cs = ProductReview.update_changeset(product_review, params)
      assert cs.valid?
    end

    test "fails for invalid params", %{product_review: product_review} do
      params = %{review_id: nil, product_id: nil}
      changeset = ProductReview.update_changeset(product_review, params)

      assert %{product_id: ["can't be blank"], review_id: ["can't be blank"]} ==
               errors_on(changeset)
    end

    test "fails for non existent review_id and product_id", %{product_review: product_review} do
      params = %{product_id: -1}
      cs = ProductReview.update_changeset(product_review, params)
      {:error, changeset} = Repo.update(cs)
      assert %{product_id: ["does not exist"]} == errors_on(changeset)

      params = %{review_id: -1}
      cs = ProductReview.update_changeset(product_review, params)
      {:error, changeset} = Repo.update(cs)
      assert %{review_id: ["does not exist"]} == errors_on(changeset)
    end
  end
end
