defmodule Snitch.Data.Schema.CardTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory
  import Ecto.Changeset, only: [apply_changes: 1]

  alias Snitch.Data.Schema.Card

  @card %{
    month: 12,
    year: 2099,
    name_on_card: "Tony Stark",
    brand: "VISA",
    number: "4111111111111111",
    card_name: "My VISA card"
  }

  @expected %{
    brand: "VISA",
    card_name: "My VISA card",
    first_digits: "411111",
    last_digits: "1111",
    month: 12,
    name_on_card: "Tony Stark",
    number: "4111111111111111",
    is_disabled: false,
    year: 2099
  }

  setup :user_with_address

  describe "card" do
    setup %{user: user} do
      [card: Map.put(@card, :user_id, user.id)]
    end

    test "with valid attributes", %{card: card} do
      %{valid?: validity} = changeset = Card.changeset(%Card{}, card, :create)
      assert validity
      assert @expected = apply_changes(changeset)
    end

    test "without card_name", %{card: card} do
      %{valid?: validity} = Card.changeset(%Card{}, card, :create)
      assert validity
    end

    test "without name of user", %{card: card} do
      card = Map.delete(card, :name_on_card)

      changeset = %{valid?: validity} = Card.changeset(%Card{}, card, :create)

      refute validity
      assert %{name_on_card: ["can't be blank"]} = errors_on(changeset)
    end

    test "without brand", %{card: card} do
      card = Map.delete(card, :brand)

      changeset = %{valid?: validity} = Card.changeset(%Card{}, card, :create)

      refute validity
      assert %{brand: ["can't be blank"]} = errors_on(changeset)
    end

    test "without user_id" do
      changeset = %{valid?: validity} = Card.changeset(%Card{}, @card, :create)

      refute validity
      assert %{user_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "with invalid month", %{card: card} do
      changeset = %{valid?: validity} = Card.changeset(%Card{}, %{card | month: 13}, :create)

      refute validity
      assert %{month: ["must be less than or equal to 12"]} = errors_on(changeset)
    end

    test "with short card number", %{card: card} do
      changeset =
        %{valid?: validity} = Card.changeset(%Card{}, %{card | number: "123456"}, :create)

      refute validity
      assert %{number: ["should be at least 8 character(s)"]} = errors_on(changeset)
    end

    test "with long card number", %{card: card} do
      changeset =
        %{valid?: validity} =
        Card.changeset(%Card{}, %{card | number: "12345678901234567890"}, :create)

      refute validity
      assert %{number: ["should be at most 19 character(s)"]} = errors_on(changeset)
    end

    test "with invalid card number", %{card: card} do
      changeset =
        %{valid?: validity} = Card.changeset(%Card{}, %{card | number: "1234AB!56"}, :create)

      refute validity
      assert %{number: ["has invalid format"]} = errors_on(changeset)
    end

    test "with invalid year", %{card: card} do
      %{year: current_year} = DateTime.utc_now()

      changeset =
        %{valid?: validity} = Card.changeset(%Card{}, %{card | year: current_year - 1}, :create)

      refute validity
      assert %{year: ["must be greater than or equal to #{current_year}"]} == errors_on(changeset)
    end

    test "can be disabled", %{card: card} do
      old_card = Card.changeset(%Card{}, card, :create)

      assert %{
               valid?: true,
               changes: %{
                 is_disabled: true
               }
             } = Card.changeset(apply_changes(old_card), %{is_disabled: true}, :update)
    end
  end
end
