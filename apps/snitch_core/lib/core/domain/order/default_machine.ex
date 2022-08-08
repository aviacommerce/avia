defmodule Snitch.Domain.Order.DefaultMachine do
  @moduledoc """
  The (default) Order state machine.

  The state machine is describe using DSL provided by `BeepBop`.
  Features:
  * handle both cash-on-delivery and credit/debit card payments

  ## Customizing the state machine

  There is no DSL or API to change the `DefaultMachine`, the developer must make
  their own module, optionally making use of DSL from `BeepBop`.

  This allows the developer to change everything, from the names of the state to
  the names of the event-callbacks.

  ## Writing a new State Machine

  The state machine module must define the following functions:
  _document this pls!_

  ### Tips
  `BeepBop` is specifically designed to used in defining state-machines for
  Snitch. You will find that the design and usage is inspired from
  `Ecto.Changeset` and `ExUnit` setups

  The functions that it injects conform to some simple rules:
  1. signature:
     ```
     @spec the_event(BeepBop.Context.t) :: BeepBop.Context.t
     ```
  2. The events consume and return contexts. BeepBop can manage simple DB
     operations for you like,
     - accumulating DB updates in an `Ecto.Multi`, and run it only if the
       whole event transition goes smoothly without any errors.
       Essentially run the event callback in a DB transaction.
     - auto updating the `order`'s `:state` as the last step of the callback.

  Make use of the helpers provided in `Snitch.Domain.Order.Transitions`! They
  are well documented and can be composed really well.

  ### Additional information

  The "states" of an `Order` are known only at compile-time. Hence other
  modules/functions that perform some logic based on the state need to be
  generated or configured at compile-time as well.
  """

  # TODO: How to attach the additional info like ability, etc with the states?
  # TODO: make the order state machine a behaviour to simplify things.

  use Snitch.Domain
  use BeepBop, ecto_repo: Repo

  alias Snitch.Data.Schema.Order
  alias Snitch.Domain.Order.Transitions

  state_machine Order, :state, ~w(cart address payment delivery processing rts shipping
                  complete cancelled confirmed balance_due)a do
    event(:add_addresses, %{from: [:cart], to: :address}, fn context ->
      context
      |> Transitions.associate_address()
      |> Transitions.compute_shipments()
      |> Transitions.persist_shipment()
    end)

    event(:payment_to_address, %{from: [:payment], to: :address}, fn context ->
      context
      |> Transitions.remove_shipment()
      |> Transitions.remove_payment_record()
      |> Transitions.associate_address()
      |> Transitions.compute_shipments()
      |> Transitions.persist_shipment()
    end)

    event(:delivery_to_address, %{from: [:delivery, :address], to: :address}, fn context ->
      context
      |> Transitions.remove_shipment()
      |> Transitions.associate_address()
      |> Transitions.compute_shipments()
      |> Transitions.persist_shipment()
    end)

    event(:add_shipments, %{from: [:address], to: :delivery}, fn context ->
      Transitions.persist_shipping_preferences(context)
    end)

    event(:add_payment, %{from: [:delivery], to: :payment}, fn context ->
      Transitions.make_payment_record(context)
    end)

    event(:save_shipping_preferences, %{from: [:address], to: :delivery}, fn context ->
      Transitions.persist_shipping_preferences(context)
    end)

    event(:confirm_purchase_payment, %{from: [:payment], to: :confirmed}, fn context ->
      context
      |> Transitions.confirm_order_payment_status()
      |> Transitions.process_shipments()
      |> Transitions.update_stock()
      |> Transitions.send_email_confirmation()
    end)

    event(:confirm_cod_payment, %{from: [:payment], to: :confirmed}, fn context ->
      context
      |> Transitions.process_shipments()
      |> Transitions.update_stock()
      |> Transitions.send_email_confirmation()
    end)

    event(:complete_order, %{from: [:confirmed], to: :complete}, fn context ->
      Transitions.check_order_completion(context)
    end)

    event(:captured, %{from: [:processing], to: :rts}, fn context ->
      context
    end)

    event(
      :payment_pending,
      %{from: %{not: ~w(cart address payment cancelled)a}, to: :payment},
      fn context ->
        context
      end
    )

    event(:ship, %{from: ~w[rts processing]a, to: :shipping}, fn context ->
      context
    end)

    event(:recieved, %{from: [:shipping], to: :complete}, fn context ->
      context
    end)

    event(:cancel, %{from: %{not: ~w(shipping complete cart)a}, to: :cancelled}, fn context ->
      context
    end)
  end

  def persist(%Order{} = order, to_state) do
    order
    |> Order.partial_update_changeset(%{state: to_state})
    |> Repo.update()
  end
end
