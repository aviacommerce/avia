defmodule Snitch.Data.Schema.CardTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.Card

  @card %{
    last_digits: "0821",
    month: 12,
    year: 2050,
    name_on_card: "Harry Potter",
    brand: "VISA"
  }

  setup :user_with_address

  describe "Cards" do
    test "with valid attributes", context do
      %{valid?: validity} =
        Card.changeset(%Card{}, Map.put(@card, :user_id, context.user.id), :create)

      assert validity
    end

    test "with invalid last_digits", context do
      card = Map.put(@card, :last_digits, "1F44")

      changeset =
        %{valid?: validity} =
        Card.changeset(%Card{}, Map.put(card, :user_id, context.user.id), :create)

      refute validity
      assert %{last_digits: ["has invalid format"]} = errors_on(changeset)
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

    test "with invalid year", context do
      current_year = DateTime.utc_now() |> Map.fetch!(:year)
      card = Map.put(@card, :year, current_year - 1)

      changeset =
        %{valid?: validity} =
        Card.changeset(%Card{}, Map.put(card, :user_id, context.user.id), :create)

      refute validity
      assert %{year: ["must be greater than or equal to #{current_year}"]} == errors_on(changeset)
    end
  end
end
