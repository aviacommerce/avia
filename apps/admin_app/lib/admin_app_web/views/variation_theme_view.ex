defmodule AdminAppWeb.VariationThemeView do
  use AdminAppWeb, :view

  def get_option_types(option_types) do
    Enum.map(option_types, fn option_type -> {option_type.display_name, option_type.id} end)
  end
end
