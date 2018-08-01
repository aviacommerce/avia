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
    state_id: nil,
    country_id: nil,
    user_id: nil
  }

  describe "changeset/3 for creation" do
    test "fails if required stuff is missing" do
      cs = Address.changeset(%Address{}, %{})
      refute cs.valid?

      assert %{
               address_line_1: ["can't be blank"],
               city: ["can't be blank"],
               first_name: ["can't be blank"],
               last_name: ["can't be blank"],
               zip_code: ["can't be blank"],
               country_id: ["can't be blank"],
               user_id: ["can't be blank"]
             } = errors_on(cs)
    end

    test "fails when address_line_1 is less than 10 chars long" do
      short = %{@params | address_line_1: "123456789"}

      cs = Address.changeset(%Address{}, short)
      refute cs.valid?

      assert %{
               address_line_1: ["should be at least 10 character(s)"],
               country_id: ["can't be blank"],
               user_id: ["can't be blank"]
             } = errors_on(cs)
    end
  end

  describe "changeset/3 for creation (state, country)" do
    setup do
      user = insert(:user)
      {:ok, user: user}
    end

    test "succeeds with valid params", %{user: user} do
      state = insert(:state)

      params = %{
        @params
        | country_id: state.country_id,
          state_id: state.id,
          user_id: user.id
      }

      %{valid?: validity} = Address.changeset(%Address{}, params)
      assert validity
    end

    test "succeeds w/o state/state_id if it is not needed in country", %{user: user} do
      country = insert(:country, states_required: false)

      params = %{
        @params
        | country_id: country.id,
          user_id: user.id
      }

      cs = Address.changeset(%Address{}, params)
      assert cs.valid?
    end

    test "fails with bad country_id", %{user: user} do
      params = %{
        @params
        | country_id: -1,
          user_id: user.id
      }

      cs = Address.changeset(%Address{}, params)
      refute cs.valid?
      assert %{country_id: ["does not exist"]} = errors_on(cs)
    end

    test "fails with bad state_id", %{user: user} do
      country = insert(:country)

      params = %{
        @params
        | country_id: country.id,
          user_id: user.id,
          state_id: -1
      }

      cs = Address.changeset(%Address{}, params)
      refute cs.valid?
      assert %{state_id: ["does not exist"]} = errors_on(cs)
    end

    test "fails without state if it was needed by country", %{user: user} do
      state = insert(:state)
      assert state.country.states_required

      params = %{
        @params
        | country_id: state.country.id,
          user_id: user.id
      }

      cs = Address.changeset(%Address{}, params)
      refute cs.valid?
      assert %{state_id: ["state is explicitly required for this country"]} = errors_on(cs)
    end

    test "fails if state.country different from country", %{user: user} do
      state = insert(:state)
      country = insert(:country)

      params = %{
        @params
        | country_id: country.id,
          state_id: state.id,
          user_id: user.id
      }

      cs = Address.changeset(%Address{}, params)

      refute cs.valid?
      assert %{state: ["state does not belong to country"]} = errors_on(cs)
    end
  end

  describe "changeset/3 for update" do
    setup do
      user = insert(:user)
      [address: insert(:address, user_id: user.id), user: user]
    end

    test "succeeds even when there is no 'change'", %{address: a} do
      cs = Address.changeset(a, %{})
      assert cs.valid?
      assert cs.changes == %{}
    end

    test "succeeds with 'change' in both country and state", %{address: a} do
      state = insert(:state)

      params =
        %{
          @params
          | country_id: state.country.id,
            state_id: state.id
        }
        |> Map.delete(:user_id)

      cs = Address.changeset(a, params)
      assert cs.valid?
      assert {:ok, _} = Repo.update(cs)
    end

    test "succeeds with 'change' in only state (of same country)", %{address: a} do
      state = insert(:state, country: a.country)

      params =
        @params
        |> Map.put(:state_id, state.id)
        |> Map.delete(:country_id)
        |> Map.delete(:user_id)

      cs = Address.changeset(a, params)
      assert cs.valid?
      assert {:ok, _} = Repo.update(cs)
    end

    test "fails with 'change' in only state (of other country)", %{address: a} do
      state = insert(:state)

      params =
        @params
        |> Map.put(:state_id, state.id)
        |> Map.delete(:country_id)
        |> Map.delete(:user_id)

      cs = Address.changeset(a, params)
      refute cs.valid?
      assert %{state: ["state does not belong to country"]} = errors_on(cs)
    end

    test "fails with 'change' in only country that has states", %{address: a} do
      country = insert(:country)
      params = %{@params | country_id: country.id, user_id: a.id}

      cs = Address.changeset(a, params)
      refute cs.valid?
      assert %{state_id: ["state is explicitly required for this country"]} = errors_on(cs)
    end

    test "succeds with 'change' in only country that has no states", %{address: a} do
      country = insert(:country, states_required: false)
      params = %{@params | country_id: country.id, state_id: -1, user_id: a.id}

      cs = Address.changeset(a, params)
      assert cs.valid?
      assert %{state_id: nil} = cs.changes
    end
  end
end
