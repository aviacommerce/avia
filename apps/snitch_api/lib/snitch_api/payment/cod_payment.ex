defmodule SnitchApi.CodPayment do
  alias BeepBop.Context
  alias Snitch.Data.Model.Order
  alias Snitch.Domain.Order.DefaultMachine
  alias Snitch.Core.Tools.MultiTenancy.Repo

  def make_payment(order_id) do
    with {:ok, order} <- Order.get(order_id) do
      context = Context.new(order)
      transition = DefaultMachine.confirm_cod_payment(context)
      transition_response(transition)
    else
      {:error, msg} ->
        {:error, msg}
    end
  end

  defp transition_response(%Context{errors: nil, struct: order}) do
    order = Repo.preload(order, :line_items)
    {:ok, order}
  end

  defp transition_response(%Context{errors: errors}) do
    {:error, message} = errors
    {:error, %{message: message}}
  end
end
