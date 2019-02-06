defmodule Snitch.Data.Schema.RatingOptionTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Schema.RatingOption

  @valid_attrs %{
    code: "1",
    value: 1,
    position: 1,
    rating_id: 147
  }
  describe "create_changeset/2 " do
    test "succeeds" do
      %{valid?: validity} = RatingOption.create_changeset(%RatingOption{}, @valid_attrs)
      assert validity
    end

    test "fails? with all empty" do
      c = %{valid?: validity} = RatingOption.create_changeset(%RatingOption{}, %{})
      refute validity
    end
  end

  describe "update_changeset/2 " do
    test "succeeds" do
      rating_opt = insert(:rating_option)
      c = RatingOption.update_changeset(rating_opt, %{position: 2})
      assert {:ok, new} = Repo.update(c)
      assert new.position != rating_opt.position
    end

    test "fails? with required param nil" do
      rating_opt = insert(:rating_option)
      c = RatingOption.update_changeset(rating_opt, %{position: nil, code: nil})
      refute c.valid?
      assert %{position: ["can't be blank"], code: ["can't be blank"]} == errors_on(c)
    end
  end
end
