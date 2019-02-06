defmodule Snitch.Data.Schema.ReviewTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Schema.Review
  alias Snitch.Data.Schema.{RatingOption, User}

  @valid_attrs %{
    title: "first review",
    description: "2",
    approved: false,
    locale: "ss",
    name: "ss",
    rating_option_vote: %{
      rating_option: %RatingOption{
        code: "1",
        position: 1,
        value: 1
      }
    }
  }

  describe "create_changeset/2 " do
    test "succeeds" do
      p2 = insert(:user)
      param = Map.put(@valid_attrs, :user_id, p2.id)
      assert cs = %{valid?: true} = Review.create_changeset(%Review{}, param)
      d = Repo.insert!(cs)
    end

    test "fails" do
      c = Review.create_changeset(%Review{}, %{})
      refute c.valid?

      assert %{
               rating_option_vote: ["can't be blank"],
               description: ["can't be blank"],
               user_id: ["can't be blank"],
               name: ["can't be blank"]
             } == errors_on(c)
    end
  end

  describe "update_changeset/2 " do
    test "succeeds" do
      p2 = insert(:user)
      param = Map.put(@valid_attrs, :user_id, p2.id)
      rev = Review.create_changeset(%Review{}, param) |> Repo.insert!()
      cs = Review.update_changeset(rev, %{description: "hello"})
      assert {:ok, new} = Repo.update(cs)
      refute t = rev.description == new.description
    end
  end
end
