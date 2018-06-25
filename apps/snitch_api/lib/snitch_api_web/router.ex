defmodule SnitchApiWeb.Router do
  use SnitchApiWeb, :router

  pipeline :api do
    plug(:accepts, ["json-api", "json"])
    plug(JaSerializer.Deserializer)
  end

  scope "/api/v1", SnitchApiWeb do
    pipe_through(:api)

    resources("/orders", OrdersController, only: [:index])
  end
end
