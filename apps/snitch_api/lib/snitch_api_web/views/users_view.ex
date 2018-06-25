defmodule SnitchApiWeb.UsersView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  location("/users/:id")

  attributes([:id, :name])
end
