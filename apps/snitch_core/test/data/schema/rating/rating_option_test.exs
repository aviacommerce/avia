defmodule Snitch.Data.Schema.RatingOptionTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Schema.RatingOption

  setup :rating_options

  @tag rating_option_count: 1
  describe "create_changeset/2" do
    test "returns a valid changeset", %{rating_options: [rating_option]} do
      rating_option = Map.from_struct(rating_option)
      changeset = RatingOption.create_changeset(%RatingOption{}, rating_option)
      assert changeset.valid?
    end

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
