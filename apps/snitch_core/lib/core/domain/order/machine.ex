defmodule Snitch.Domain.Order.Machine do
  use Snitch.Domain
  use BeepBop, ecto_repo: Repo

  alias Snitch.Domain.Order.Transitions
  alias Snitch.Data.Schema.Order

  state_machine Order,
                :state,
                ~w(cart address payment processing rts shipping complete cancelled)a do
    event(:add_addresses, %{from: [:cart], to: :address}, fn state ->
      state
      |> Transitions.associate_address()
      |> Transitions.compute_shipments()
    end)

    event(:add_payment, %{from: [:address], to: :payment}, fn state ->
      state
    end)

    event(:confirm, %{from: [:payment], to: :processing}, fn state ->
      state
    end)

    event(:captured, %{from: [:processing], to: :rts}, fn state ->
      state
    end)

    event(
      :payment_pending,
      %{from: %{not: ~w(cart address payment cancelled)a}, to: :payment},
      fn state ->
        state
      end
    )

    event(:ship, %{from: ~w[rts processing]a, to: :shipping}, fn state ->
      state
    end)

    event(:recieved, %{from: [:shipping], to: :complete}, fn state ->
      state
    end)

    event(:cancel, %{from: %{not: ~w(shipping complete cart)a}, to: :cancelled}, fn state ->
      state
    end)
  end
end
