defmodule ApiWeb.Router do
  use ApiWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api/v1", ApiWeb, as: :api_v1 do
    pipe_through(:api)

    get("/taxonomies", TaxonomyController, :index)

    scope("/orders") do
      get("/current", OrderController, :current)
      post("/", OrderController, :create)
    end
  end
end
