defmodule SnitchApiWeb.OptionTypeView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :display_name,
    :name
  ])
end
