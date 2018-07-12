defmodule SnitchApiWeb.UserView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  location("/users/:id")

  attributes([:name, :email])

  def name(user, _conn) do
    user
    |> Map.take([:first_name, :last_name])
    |> Map.values()
    |> List.to_string()
  end

  def render("token.json-api", %{data: token}) do
    %{token: token}
  end

  def render("logout.json-api", %{data: status}) do
    %{status: status}
  end

  def render("current_user.json-api", %{data: user}) do
    %{data: Map.take(user, [:email, :first_name, :last_name, :id])}
  end
end
