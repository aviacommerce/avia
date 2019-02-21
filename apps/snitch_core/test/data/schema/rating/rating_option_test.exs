defmodule Snitch.Data.Schema.RatingOptionTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Schema.RatingOption

  setup :rating_options

  describe "create_changeset/2" do
    setup %{rating_options: [rating_option]} do
      params = %{
        code: rating_option.code,
        value: rating_option.value,
        position: rating_option.position,
        rating_id: rating_option.rating_id
      }

      [params: params]
    end

    @tag rating_option_count: 1
    test "returns a valid changeset", %{params: params} do
      changeset = RatingOption.create_changeset(%RatingOption{}, params)
      assert changeset.valid?
    end

    @tag rating_option_count: 1
    test "fails for invalid params" do
      changeset = RatingOption.create_changeset(%RatingOption{}, %{})
      refute changeset.valid?

      assert %{
               code: ["can't be blank"],
               value: ["can't be blank"],
               position: ["can't be blank"],
               rating_id: ["can't be blank"]
             } == errors_on(changeset)
    end

    @tag rating_option_count: 1
    test "fails for non-existent rating_id", %{params: params} do
      params = %{params | rating_id: -1}
      cs = RatingOption.create_changeset(%RatingOption{}, params)
      {:error, changeset} = Repo.insert(cs)
      assert %{rating_id: ["does not exist"]} == errors_on(changeset)
    end
  end

  describe "update_changeset/2 " do
    @tag rating_option_count: 1
    test "returns a valid changeset", %{rating_options: [rating_option]} do
      params = %{position: 43}
      changeset = RatingOption.update_changeset(rating_option, params)
      {:ok, new} = Repo.update(changeset)
      assert new.position != rating_option.position
    end

    @tag rating_option_count: 1
    test "fails for invalid params", %{rating_options: [rating_option]} do
      params = %{position: nil, code: nil}
      changeset = RatingOption.update_changeset(rating_option, params)
      refute changeset.valid?
      assert %{position: ["can't be blank"], code: ["can't be blank"]} == errors_on(changeset)
    end
  end
end
