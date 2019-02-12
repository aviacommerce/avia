defmodule AdminAppWeb.Router do
  use AdminAppWeb, :router
  use Sentry.Plug
  import Snitch.Core.Tools.MultiTenancy.Repo, only: [get_prefix: 0]

  @secret_key_base Application.get_env(:admin_app, AdminAppWeb.Endpoint)[:secret_key_base]

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  defp put_user_token(conn, _) do
    if current_user = conn.assigns[:current_user] do
      token = Phoenix.Token.sign(conn, @secret_key_base, "#{get_prefix()}_#{current_user.id}")
      assign(conn, :user_token, token)
    else
      conn
    end
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
    plug(Auth.CurrentUser)
    plug(:put_user_token)
  end

  scope "/", AdminAppWeb do
    # Use the default browser stack
    pipe_through([:browser, :authentication])

    get("/", PageController, :index)

    get("/products/export_products", ProductController, :export_product)
    get("/fetch_states/:country_id", StockLocationController, :fetch_country_states)
    get("/orders/export_orders", OrderController, :export_order)
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
    resources("/general_settings", GeneralSettingsController, except: [:delete])
    post("/payment-provider-inputs", PaymentMethodController, :payment_preferences)
    get("/product/category", ProductController, :select_category)
    post("/product-images/:product_id", ProductController, :add_images)
    post("/set-default-image/:product_id", ProductController, :update_default_image)
    delete("/product-images/", ProductController, :delete_image)

    get("/taxonomy", TaxonomyController, :show_default_taxonomy)
    resources("/taxonomy", TaxonomyController, only: [:create])

    get("/products/:product_id/property", ProductController, :index_property)
    get("/products/:product_id/property/new", ProductController, :new_property)
    get("/products/:product_id/property/:property_id/edit", ProductController, :edit_property)
    post("/products/:product_id/property/create", ProductController, :create_property)

    patch(
      "/products/:product_id/inventory_tracking",
      ProductController,
      :update_inventory_tracking
    )

    get("/dashboard", DashboardController, :index)

    post(
      "/products/:product_id/property/:property_id/update",
      ProductController,
      :update_property
    )

    delete(
      "/products/:product_id/property/:property_id/delete",
      ProductController,
      :delete_property
    )

    delete("/variant_delete/:id", ProductController, :delete_variant)

    get("/shipping-policy/new", ShippingPolicyController, :new)
    get("/shipping-policy/:id/edit", ShippingPolicyController, :edit)
    put("/shipping-policy/:id", ShippingPolicyController, :update)
    get("/product/import/etsy", ProductImportController, :import_etsy)
    get("/product/import/etsy/callback", ProductImportController, :oauth_callback)
    get("/product/import/etsy/progress", ProductImportController, :import_progress)

    ### tax
    get("/tax", Tax.TaxConfigController, :index)
    put("/tax/:id", Tax.TaxConfigController, :update)
    get("/tax/tax-classes", Tax.TaxClassController, :index)
    get("/tax/tax-classes/new", Tax.TaxClassController, :new)
    get("/tax/tax-classes/:id/edit", Tax.TaxClassController, :edit)
    post("/tax/tax-classes/new", Tax.TaxClassController, :create)
    put("/tax/tax-classes/:id", Tax.TaxClassController, :update)
    delete("/tax/tax-classes/:id", Tax.TaxClassController, :delete)

    resources("/tax/tax-zones", Tax.TaxZoneController, except: [:show]) do
      resources("/tax-rates", Tax.TaxRateController, except: [:show])
    end
  end

  scope "api/", AdminAppWeb do
    ### promotions

    resources("/promotions", PromotionController, except: [:show, :new])
    get("/promo-rules", PromotionController, :rules, as: :promo_rules)
    get("/promo-actions", PromotionController, :actions, as: :promo_actions)
    get("/promo-calculators", PromotionController, :calculators, as: :promo_calc)
    post("/promo-rule-prefs", PromotionController, :rule_preferences, as: :promo_rule_prefs)
    post("/promo-action-prefs", PromotionController, :action_preferences, as: :promo_action_prefs)
    post("/promo-calc-prefs", PromotionController, :calc_preferences, as: :promo_calc_prefs)
    put("/promo/:id/archive", PromotionController, :archive)
  end

  scope "/", AdminAppWeb do
    pipe_through(:avoid_csrf)
    patch("/variant_state/:id", ProductController, :toggle_variant_state)
    post("/products/variants/new", ProductController, :new_variant)
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
    delete("/taxon/:taxon_id", TaxonomyController, :taxon_delete)
    get("/taxon/:taxon_id/aggregate", TaxonomyController, :taxon_delete_aggregate)
    put("/taxonomy/update", TaxonomyController, :update_taxon)
    post("/product_option_values/:id", OptionTypeController, :update)
  end

  scope "/api", AdminAppWeb.Api do
    pipe_through(:api)

    post("/stock", StockController, :get_stock)
    post("/stock_update", StockController, :update_stock)
  end

  scope "/", AdminAppWeb do
    pipe_through([:browser, :authentication])

    # Don't add phoenix routes after this route as, all routes that does not match
    # Phoenix routes goes to react app.
    get("/*path", ReactController, :index)
  end
end
