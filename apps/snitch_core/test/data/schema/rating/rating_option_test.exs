defmodule Snitch.Data.Schema.RationOptionTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  alias Snitch.Data.Schema.RatingOption

  @valid_attrs %{
    code: "1",
    value: 1,
    position: 1,
    rating_id: 105
  }
  describe "create_changeset/2 " do
    test "succeeds" do
      %{valid?: validity} = RatingOption.create_changeset(%RatingOption{}, @valid_attrs)
      assert validity
    end

    test "fails? with missing code" do
      param = Map.delete(@valid_attrs, :code)
      c = %{valid?: validity} = RatingOption.create_changeset(%RatingOption{}, param)
      refute validity
      assert %{code: ["can't be blank"]} = errors_on(c)
    end

    test "fails? with missing value" do
      param = Map.delete(@valid_attrs, :value)
      c = %{valid?: validity} = RatingOption.create_changeset(%RatingOption{}, param)
      refute validity
      assert %{value: ["can't be blank"]} = errors_on(c)
    end

    test "fails? with missing position" do
      param = Map.delete(@valid_attrs, :position)
      c = %{valid?: validity} = RatingOption.create_changeset(%RatingOption{}, param)
      refute validity
      assert %{position: ["can't be blank"]} = errors_on(c)
    end

    test "fails? with missing rating_id" do
      param = Map.delete(@valid_attrs, :rating_id)
      c = %{valid?: validity} = RatingOption.create_changeset(%RatingOption{}, param)
      refute validity
      assert %{rating_id: ["can't be blank"]} = errors_on(c)
    end

    test "fails? with all empty" do
      %{valid?: validity} = RatingOption.create_changeset(%RatingOption{}, %{})
      refute validity
    end
  end

  describe "update_changeset/2 " do
    test "succeeds" do
      param = Map.put(@valid_attrs, :position, 2)
      %{valid?: validity} = RatingOption.update_changeset(%RatingOption{}, param)
      assert validity
    end

    test "fails? without position" do
      param = Map.delete(@valid_attrs, :position)
      c = %{valid?: validity} = RatingOption.update_changeset(%RatingOption{}, param)
      refute validity
      assert %{position: ["can't be blank"]} = errors_on(c)
    end

    test "fails? without code" do
      param = Map.delete(@valid_attrs, :code)
      c = %{valid?: validity} = RatingOption.update_changeset(%RatingOption{}, param)
      refute validity
      assert %{code: ["can't be blank"]} = errors_on(c)
    end

    test "fails? with all empty" do
      %{valid?: validity} = RatingOption.update_changeset(%RatingOption{}, %{})
      refute validity
    end
  end
end
