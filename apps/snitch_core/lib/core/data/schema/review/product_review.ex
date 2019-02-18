defmodule Snitch.Data.Schema.ProductReview do
  @moduledoc """
  Models product review.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{Product, Review, User}

  @type t :: %__MODULE__{}

  schema "snitch_product_reviews" do
    belongs_to(:product, Product)
    belongs_to(:review, Review)
    belongs_to(:user, User)

    timestamps()
  end

  @required_params ~w(product_id review_id user_id)a

  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = product_review, params) do
    common_changeset(product_review, params)
  end

  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = product_review, params) do
    common_changeset(product_review, params)
  end

  defp common_changeset(product_review, params) do
    product_review
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> foreign_key_constraint(:product_id)
    |> foreign_key_constraint(:review_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:user_id)
  end
end
