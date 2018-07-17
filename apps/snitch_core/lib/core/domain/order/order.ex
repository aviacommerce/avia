defmodule Snitch.Domain.Order do
  @moduledoc """
  Order helpers.
  """

  @editable_states ~w(cart address delivery payment)

  use Snitch.Domain

  import Ecto.Changeset

  alias Snitch.Data.Schema.Order

  @spec validate_change(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_change(%{valid?: false} = changeset), do: changeset

  def validate_change(%{valid?: true} = changeset) do
    prepare_changes(changeset, fn changeset ->
      with {_, order_id} <- fetch_field(changeset, :order_id),
           %Order{state: order_state} <- changeset.repo.get(Order, order_id) do
        if order_state in @editable_states do
          changeset
        else
          add_error(changeset, :order, "has been frozen", validation: :state, state: order_state)
        end
      else
        _ ->
          changeset
      end
    end)
  end
end
