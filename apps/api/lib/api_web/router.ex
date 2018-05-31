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
      get("/:order_number/payments/new", PaymentController, :payment_methods)
      post("/:order_number/line_items/", OrderController, :add_line_item)
    end

    get("/products", ProductController, :index)
    get("/products/:product_slug", ProductController, :product)
  end
end
