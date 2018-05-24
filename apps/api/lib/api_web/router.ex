defmodule ApiWeb.Router do
  use ApiWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api/v1", ApiWeb do
    pipe_through(:api)

    get("/taxonomies", TaxonomyController, :index)
  end
end
