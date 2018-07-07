defmodule SnitchApiWeb.Router do
  use SnitchApiWeb, :router

  pipeline :api do
    plug(:accepts, ["json-api", "json"])
    plug(JaSerializer.Deserializer)
  end

  scope "/api/v1", SnitchApiWeb do
    pipe_through(:api)

    # user sign_in_out_up
    post("/register", UserController, :create)
    get("/users/:id", UserController, :show)
    post("/login", UserController, :login)
    post("/logout", UserController, :logout)

    resources("/orders", OrderController, only: [:index])
    resources("/taxonomies", TaxonomyController, only: [:index, :show])
    resources("/taxons", TaxonController, only: [:index, :show])

    resources("/products", ProductController, only: [:index, :show], param: "product_slug") do
      resources("/variants", VariantController, only: [:index])
    end
  end
end
