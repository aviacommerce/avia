defmodule Snitch.Domain.Order do
  @moduledoc """
  Order helpers
  """

  use Snitch.Domain

  alias Snitch.Data.Schema.Order

  def add_line_item(%Order{state: "cart"} = order, _), do: {:ok, order}

  def update_line_item(%Order{state: "cart"} = order, _), do: {:ok, order}

  def remove_line_item(%Order{state: "cart"} = order, _), do: {:ok, order}
end
