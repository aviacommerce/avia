defmodule AdminAppWeb.Router do
  use AdminAppWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    # plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :authentication do
    plug(AdminAppWeb.AuthenticationPipe)
  end

  scope "/", AdminAppWeb do
    # Use the default browser stack
    pipe_through([:browser, :authentication])

    get("/", PageController, :index)

    resources "/orders", OrderController, only: ~w[index show create]a, param: "number" do
      get("/cart", OrderController, :get, as: :cart)
      post("/cart", OrderController, :remove_item, as: :cart)
      post("/cart/edit", OrderController, :edit, as: :cart)
      put("/cart/update", OrderController, :update_line_item, as: :cart)
      put("/cart", OrderController, :add, as: :cart)
      get("/address/search", OrderController, :address_search, as: :cart)
      put("/address/search", OrderController, :address_attach, as: :cart)
      get("/address/add", OrderController, :address_add_index, as: :cart)
      post("/address/add", OrderController, :address_add, as: :cart)
    end

    resources("/tax_categories", TaxCategoryController, only: [:index, :new, :create])
    resources("/stock_locations", StockLocationController)
    resources("/option_types", OptionTypeController)
    resources("/properties", PropertyController, except: [:show])
    resources("/registrations", RegistrationController, only: [:new, :create])
    resources("/session", SessionController, only: [:delete])
    resources("/users", UserController)
    resources("/roles", RoleController)
    resources("/permissions", PermissionController)
    resources("/variation_themes", VariationThemeController, except: [:show])
    resources("/prototypes", PrototypeController, except: [:show])
  end

  scope "/", AdminAppWeb do
    pipe_through(:browser)
    resources("/session", SessionController, only: [:new, :create])
  end

  # Other scopes may use custom stacks.
  scope "/api", AdminAppWeb do
    pipe_through(:api)

    resources("/stock_locations", StockLocationController)
  end
end
