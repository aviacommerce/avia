defmodule AdminAppWeb.PrototypeView do
  use AdminAppWeb, :view

  def get_options(items) do
    Enum.map(items, fn item -> {item.name, item.id} end)
  end
end
