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
    post("/orders/blank", OrderController, :guest_order)
    get("/variants/favorites", VariantController, :favorite_variants)
  end

  scope "/api/v1", SnitchApiWeb do
    pipe_through([:api, :authenticated])

    # user sign_in_out_up
    get("/users/:id", UserController, :show)
    get("/authenticated", UserController, :authenticated)
    post("/logout", UserController, :logout)
    get("/current_user", UserController, :current_user)
    resources("/wishlist_items", WishListItemController, only: [:index, :create, :delete])
    resources("/orders", OrderController, only: [:index, :show])
    resources("/line_items", LineItemController, only: [:create, :update, :show])
    resources("/taxonomies", TaxonomyController, only: [:index, :show])
    resources("/taxons", TaxonController, only: [:index, :show])
    resources("/ratings", RatingController, only: [:index, :show])
    resources("/reviews", ReviewController, only: [:create, :update, :delete])
    get("/product/:id/rating-summary", ProductController, :rating_summary)
  end
end
