defmodule Snitch.Data.Model.CardTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory
  alias Snitch.Data.Model.Card
  alias Snitch.Data.Schema.Card, as: CardSchema

  @card %{
    month: 12,
    year: 2099,
    name_on_card: "Tony Stark",
    brand: "VISA",
    number: "4111111111111111",
    card_name: "My VISA card"
  }

  setup :user_with_address

  describe "create/1" do
    setup %{user: user} do
      [card: Map.put(@card, :user_id, user.id)]
    end

    test "with valid attribute", %{card: card} do
      assert {:ok, %CardSchema{}} = Card.create(card)
    end

    test "FAILS for invalid attributes", %{card: card} do
      bad_card = Map.put(card, :number, "4111111")
      assert {:error, changeset} = Card.create(bad_card)
      refute changeset.valid?
    end
  end
end
