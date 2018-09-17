defmodule AdminAppWeb.TemplateApi.OptionTypeView do
  use AdminAppWeb, :view

  def render("option_value.json", %{option_value: option_value}) do
    Map.take(option_value, [:value, :option_type_id, :display_name])
  end
end
