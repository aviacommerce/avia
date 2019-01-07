defmodule SnitchApiWeb.Router do
  use SnitchApiWeb, :router
  use Plug.ErrorHandler
  # use Sentry.Plug

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
    get("/products/suggest", ProductController, :suggest)
    resources("/products", ProductController, except: [:new, :edit], param: "product_slug")
    get("/orders/:order_number", OrderController, :fetch_guest_order)
    post("/hosted-payment/:payment_source/success", HostedPaymentController, :payment_success)
    post("/hosted-payment/:payment_source/error", HostedPaymentController, :payment_error)
    resources("/taxonomies", TaxonomyController, only: [:index, :show])
    resources("/taxons", TaxonController, only: [:index, :show])
    get("/countries", AddressController, :countries)
    get("/countries/:id/states/", AddressController, :country_states)
    get("/brands", ProductBrandController, :index)
    post("/product_option_values/:id", ProductOptionValueController, :update)
    post("/guest/line_items", LineItemController, :guest_line_item)
    resources("/ratings", RatingController, only: [:index, :show])
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
    delete("/line_items", LineItemController, :delete)
    post("/orders/:id/select_address", OrderController, :select_address)
    post("/orders/:id/add-payment", OrderController, :add_payment)
    patch("/orders/:id/add-shipment", OrderController, :add_shipments)
    post("/orders/current", OrderController, :current)
    resources("/reviews", ReviewController, only: [:create, :update, :delete])
    get("/product/:id/rating-summary", ProductController, :rating_summary)
    get("/product/:id/reviews", ProductController, :reviews)
    resources("/addresses", AddressController, only: [:index, :show, :create, :update, :delete])
    get("/payment/payment-methods", PaymentController, :payment_methods)
    post("/payment/cod_payment", PaymentController, :cod_payment)
    post("/promotion/apply", PromotionController, :apply)

    # TODO: https://github.com/aviacommerce/avia/issues/283
    # We have fixed the routes as per the payment providers for now.
    # This needs to be refactored such that there is just one endpoint
    # for success and one for failure
    # At controller level, the handling should be generic. Any provider
    # specific code should go inside
    # 1. avia_payments https://github.com/aviacommerce/avia_payments
    #                             OR
    # 2. gringotts https://github.com/aviabird/gringotts/

    post("/hosted-payment/payubiz-request", HostedPaymentController, :payubiz_request_url)
    get("/hosted-payment/stripe-request", HostedPaymentController, :stripe_request_params)
    post("/hosted-payment/stripe-pay", HostedPaymentController, :stripe_purchase)
    get("/hosted-payment/rzpay-request", HostedPaymentController, :rzpay_request_params)
    post("/hosted-payment/rzpay", HostedPaymentController, :rzpay_purchase)
  end
end
