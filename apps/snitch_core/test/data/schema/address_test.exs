defmodule Snitch.Data.Schema.AddressTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.{Address, Country}

  @valid_params %{
    first_name: "Tony",
    last_name: "Stark",
    address_line_1: "10-8-80 Malibu Point",
    zip_code: "90265",
    city: "Malibu",
    phone: "1234567890"
  }

  describe "create_changeset/3" do
    test "fails if required stuff is missing" do
      cs = %{valid?: validity} = Address.create_changeset(%Address{}, %{}, %Country{})
      refute validity

      assert %{
               address_line_1: ["can't be blank"],
               city: ["can't be blank"],
               first_name: ["can't be blank"],
               last_name: ["can't be blank"],
               zip_code: ["can't be blank"]
             } = errors_on(cs)
    end

    test "fails when address_line_1 is less than 10 chars long" do
      short = %{@valid_params | address_line_1: "123456789"}

      cs = %{valid?: validity} = Address.create_changeset(%Address{}, short, %Country{})
      refute validity

      assert %{
               address_line_1: ["should be at least 10 character(s)"]
             } = errors_on(cs)
    end
  end

  describe "create_changeset/3 and state, country" do
    setup :states
    setup :countries

    test "with valid params", %{states: [state]} do
      %{valid?: validity} =
        Address.create_changeset(%Address{}, @valid_params, state.country, state)

      assert validity
    end

    test "without state if it is not needed in country", %{countries: [country]} do
      tweaked_country = %{country | states_required: false}

      %{valid?: validity} = Address.create_changeset(%Address{}, @valid_params, tweaked_country)

      assert validity
    end

    test "fails without state if it is needed", %{countries: [country]} do
      assert country.states_required
      cs = %{valid?: validity} = Address.create_changeset(%Address{}, @valid_params, country)
      refute validity
      assert %{state: ["state is required for this country"]} = errors_on(cs)
    end

    test "fails if state.country different from country", %{states: [state], countries: [country]} do
      cs =
        %{valid?: validity} = Address.create_changeset(%Address{}, @valid_params, country, state)

      refute validity
      assert %{state: ["state does not belong to country"]} = errors_on(cs)
    end
  end
end
