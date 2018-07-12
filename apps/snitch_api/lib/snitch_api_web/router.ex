defmodule SnitchApiWeb.Router do
  use SnitchApiWeb, :router

  alias SnitchApiWeb.Guardian

  pipeline :api do
    plug(:accepts, ["json-api", "json"])
    plug(JaSerializer.Deserializer)
  end

  pipeline :authenticated do
    plug(Guardian.AuthPipeline)
  end

  scope "/api/v1", SnitchApiWeb do
    pipe_through(:api)
    # user sign_in_up
    post("/register", UserController, :create)
    post("/login", UserController, :login)
  end

  scope "/api/v1", SnitchApiWeb do
    pipe_through([:api, :authenticated])

    # user sign_in_out_up
    get("/users/:id", UserController, :show)
    post("/logout", UserController, :logout)
    get("/current_user", UserController, :current_user)
    resources("/orders", OrderController, only: [:index, :show])
    post("/orders/blank", OrderController, :guest_order)

    resources("/taxonomies", TaxonomyController, only: [:index, :show])
    resources("/taxons", TaxonController, only: [:index, :show])
  end
end
