defmodule Snitch.Data.Schema.AddressTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.Address

  @params %{
    first_name: "Tony",
    last_name: "Stark",
    address_line_1: "10-8-80 Malibu Point",
    zip_code: "90265",
    city: "Malibu",
    phone: "1234567890",
    state: nil,
    state_id: nil,
    country: nil,
    country_id: nil
  }

  describe "create_changeset/3" do
    test "fails if required stuff is missing" do
      cs = Address.create_changeset(%Address{}, %{})
      refute cs.valid?

      assert %{
               address_line_1: ["can't be blank"],
               city: ["can't be blank"],
               first_name: ["can't be blank"],
               last_name: ["can't be blank"],
               zip_code: ["can't be blank"],
               country: ["country or country_id can't be blank"]
             } = errors_on(cs)
    end

    test "fails when address_line_1 is less than 10 chars long" do
      short = %{@params | address_line_1: "123456789"}

      cs = Address.create_changeset(%Address{}, short)
      refute cs.valid?

      assert %{
               address_line_1: ["should be at least 10 character(s)"],
               country: ["country or country_id can't be blank"]
             } = errors_on(cs)
    end
  end

  describe "create_changeset/3 and state, country" do
    setup :states
    setup :countries

    test "succeeds with valid params", %{states: [state]} do
      params = %{
        @params
        | country: state.country,
          state: state
      }

      %{valid?: validity} = Address.create_changeset(%Address{}, params)
      assert validity

      params = %{
        @params
        | country_id: state.country_id,
          state_id: state.id
      }

      %{valid?: validity} = Address.create_changeset(%Address{}, params)
      assert validity
    end

    test "succeeds w/o state/state_id if it is not needed in country", %{countries: [country]} do
      params = %{
        @params
        | country: %{country | states_required: false}
      }

      %{valid?: validity} = Address.create_changeset(%Address{}, params)

      assert validity
    end

    test "fails with bad country_id" do
      params = %{
        @params
        | country_id: -1
      }

      cs = Address.create_changeset(%Address{}, params)
      refute cs.valid?
      assert %{country_id: ["does not exist"]} = errors_on(cs)
    end

    test "fails with bad state_id", %{countries: [country]} do
      params = %{
        @params
        | country: country,
          state_id: -1
      }

      cs = Address.create_changeset(%Address{}, params)
      refute cs.valid?
      assert %{state_id: ["does not exist"]} = errors_on(cs)
    end

    test "fails without state if it was needed by country", %{countries: [country]} do
      assert country.states_required

      params = %{
        @params
        | country_id: country.id
      }

      cs = Address.create_changeset(%Address{}, params)
      refute cs.valid?
      assert %{state: ["state is required for this country"]} = errors_on(cs)

      params = %{
        @params
        | country: country
      }

      cs = Address.create_changeset(%Address{}, params)
      refute cs.valid?
      assert %{state: ["state is required for this country"]} = errors_on(cs)
    end

    test "fails if state.country different from country", %{states: [state], countries: [country]} do
      params = %{
        @params
        | country: country,
          state: state
      }

      cs = Address.create_changeset(%Address{}, params)

      refute cs.valid?
      assert %{state: ["state does not belong to country"]} = errors_on(cs)

      params = %{
        @params
        | country_id: country.id,
          state_id: state.id
      }

      cs = Address.create_changeset(%Address{}, params)

      refute cs.valid?
      assert %{state: ["state does not belong to country"]} = errors_on(cs)
    end
  end
end
