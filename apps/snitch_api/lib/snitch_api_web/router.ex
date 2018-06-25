defmodule SnitchApiWeb.Router do
  use SnitchApiWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api/v1", SnitchApiWeb do
    pipe_through(:api)

    resources("/products", ProductController, only: [:index, :show])
  end
end
