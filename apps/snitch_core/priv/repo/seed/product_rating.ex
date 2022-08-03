defmodule Snitch.Seed.ProductRating do
  @moduledoc """
  Seed file for product rating and rating options.
  """

  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Schema.Rating
  alias Snitch.Data.Schema.RatingOption

  require Logger

  @product_rating_options [{1, "1", 1}, {2, "2", 2}, {3, "3", 3}, {4, "4", 4}, {5, "5", 5}]

  def seed do
    Repo.transaction(fn ->
      rating = Repo.insert!(%Rating{code: "product"})
      Logger.info("Inserted rating type product!")
      seed_prodcut_rating_options(rating)
    end)
  end

  def seed_prodcut_rating_options(rating) do
    options =
      Enum.map(@product_rating_options, fn {value, code, position} ->
        %{
          code: code,
          value: value,
          position: position,
          rating_id: rating.id,
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
      end)

    Repo.insert_all(RatingOption, options)
    Logger.info("Inserted rating options for product!")
  end
end
