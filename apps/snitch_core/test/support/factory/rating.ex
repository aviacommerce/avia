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

      def rating_options(context) do
        rating = insert(:rating)
        count = Map.get(context, :rating_option_count, 2)
        [rating_options: insert_list(3, :rating_option, rating: rating)]
      end
    end
  end
end
