defmodule AdminAppWeb.OrderView do
  use AdminAppWeb, :view

  @bootstrap_contextual_class_map %{
    "cart" => "",
    "address" => "",
    "payment" => "",
    "processing" => "",
    "shipping" => "",
    "shipped" => "",
    "cancelled" => "",
    "completed" => ""
  }

  def colorize(%{state: "completed"}), do: "table-success"
  def colorize(%{state: _}), do: ""
end
