defmodule AdminAppWeb.Router do
  use AdminAppWeb, :router
  use Plug.ErrorHandler
  use Sentry.Plug

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  # This pipeline is just to avoid CSRF token.
  # TODO: This needs to be remove when the token issue gets fixed in custom form
  pipeline :avoid_csrf do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
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

    get("/orders/:category", OrderController, :index)
    get("/orders", OrderController, :index)
    get("/orders/:number/detail", OrderController, :show)
    put("/orders/:id/packages/", OrderController, :update_package, as: :order_package)
    put("/orders/:id/state", OrderController, :update_state, as: :order_state)
    put("/orders/:id/cod-payment", OrderController, :cod_payment_update, as: :order_cod_update)

    resources "/orders", OrderController, only: ~w[show create]a, param: "number" do
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
    resources("/products", ProductController)
    resources("/product_brands", ProductBrandController)
    resources("/payment_methods", PaymentMethodController)
    resources("/zones", ZoneController, only: [:index, :new, :create, :edit, :update, :delete])
    post("/payment-provider-inputs", PaymentMethodController, :payment_preferences)
    get("/product/category", ProductController, :select_category)
    post("/product-images/:product_id", ProductController, :add_images)
    delete("/product-images/", ProductController, :delete_image)

    delete("/taxonomy/delete", TaxonomyController, :delete_taxonomy)
    resources("/taxonomy", TaxonomyController, except: [:update])
    post("/taxonomy/create", TaxonomyController, :create_taxonomy)
  end

  scope "/", AdminAppWeb do
    pipe_through(:avoid_csrf)
    post("/products/variants/new", ProductController, :new_variant)
    post("/product/stock", ProductController, :add_stock)
  end

  scope "/", AdminAppWeb do
    pipe_through(:browser)
    get("/orders/:number/show-invoice", OrderController, :show_invoice)
    get("/orders/:number/show-packing-slip", OrderController, :show_packing_slip)
    get("/orders/:number/download-packing-slip", OrderController, :download_packing_slip_pdf)
    get("/orders/:number/download-invoice", OrderController, :download_invoice_pdf)
    resources("/session", SessionController, only: [:new, :create, :edit, :update])
    get("/password_reset", SessionController, :password_reset)
    get("/password_recovery", SessionController, :verify)
    post("/check_email", SessionController, :check_email)
  end

  # Other scopes may use custom stacks.
  scope "/api", AdminAppWeb do
    pipe_through(:api)

    resources("/stock_locations", StockLocationController)
  end

  scope "/api", AdminAppWeb.TemplateApi do
    pipe_through(:api)

    resources("/option_types", OptionTypeController)
    get("/categories/:taxon_id", TaxonomyController, :index)
    get("/taxon/:taxon_id", TaxonomyController, :taxon_edit)
    put("/taxonomy/update", TaxonomyController, :update_taxon)
    post("/product_option_values/:id", OptionTypeController, :update)
  end
end
