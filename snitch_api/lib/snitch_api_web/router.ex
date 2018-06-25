defmodule SnitchApiWeb.Router do
  use SnitchApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SnitchApiWeb do
    pipe_through :api
  end
end
