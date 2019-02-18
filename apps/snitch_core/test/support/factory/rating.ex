defmodule Snitch.Factory.Rating do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      alias Snitch.Data.Schema.{Rating, RatingOption}

      def rating_factory do
        %Rating{
          code: "product",
          position: 0
        }
      end

      def rating_option_factory do
        %RatingOption{
          rating: build(:rating),
          code: sequence(:code, ["1", "2", "3"]),
          value: sequence(:value, [1, 2, 3]),
          position: sequence(:position, [1, 2, 3])
        }
      end

      def review_factory do
        user = insert(:user)

        %Review{
          description: "awesomeness redefined",
          user_id: user.id,
          name: "stark",
          rating_option_vote: %{
            rating_option: build(:rating_option)
          }
        }
      end

      def product_review_factory do
        %ProductReview{
          review: build(:review),
          product: build(:product),
          user: build(:user)
        }
      end

      def rating_options(context) do
        rating = insert(:rating)
        count = Map.get(context, :rating_option_count, 2)
        [rating_options: insert_list(3, :rating_option, rating: rating)]
      end
    end
  end
end
