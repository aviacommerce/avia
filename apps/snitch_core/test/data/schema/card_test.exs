defmodule Snitch.Data.Schema.CardTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.Card

  @card %{
    month: 12,
    year: 2050,
    name_on_card: "Harry Potter",
    brand: "VISA",
    number: "4111111111111111",
    is_disabled: false
  }

  setup :user_with_address
  setup :card

  describe "Cards" do
    test "with valid attributes", context do
      %{valid?: validity} =
        Card.changeset(%Card{}, Map.put(@card, :user_id, context.user.id), :create)

      assert validity
    end

    test "without name of user", context do
      card = Map.delete(@card, :name_on_card)

      changeset =
        %{valid?: validity} =
        Card.changeset(%Card{}, Map.put(card, :user_id, context.user.id), :create)

      refute validity
      assert %{name_on_card: ["can't be blank"]} = errors_on(changeset)
    end

    test "without brand", context do
      card = Map.delete(@card, :brand)

      changeset =
        %{valid?: validity} =
        Card.changeset(%Card{}, Map.put(card, :user_id, context.user.id), :create)

      refute validity
      assert %{brand: ["can't be blank"]} = errors_on(changeset)
    end

    test "without user_id" do
      changeset = %{valid?: validity} = Card.changeset(%Card{}, @card, :create)

      refute validity
      assert %{user_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "with invalid month", context do
      card = Map.put(@card, :month, 13)

      changeset =
        %{valid?: validity} =
        Card.changeset(%Card{}, Map.put(card, :user_id, context.user.id), :create)

      refute validity
      assert %{month: ["must be less than or equal to 12"]} = errors_on(changeset)
    end

    test "with invalid number", context do
      card = Map.put(@card, :number, "5431111111111")

      changeset =
        %{valid?: validity} =
        Card.changeset(%Card{}, Map.put(card, :user_id, context.user.id), :create)

      refute validity
      assert %{number: ["has invalid format"]} = errors_on(changeset)
    end

    test "with invalid year", context do
      current_year = DateTime.utc_now() |> Map.fetch!(:year)
      card = Map.put(@card, :year, current_year - 1)

      changeset =
        %{valid?: validity} =
        Card.changeset(%Card{}, Map.put(card, :user_id, context.user.id), :create)

      refute validity
      assert %{year: ["must be greater than or equal to #{current_year}"]} == errors_on(changeset)
    end

    test "is deleted", context do
      changeset = Card.changeset(context.card, %{is_disabled: true}, :update)
      assert {:ok, _} = Repo.update(changeset)
    end
  end
end
