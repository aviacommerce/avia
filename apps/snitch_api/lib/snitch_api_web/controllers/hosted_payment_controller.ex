defmodule SnitchApiWeb.HostedPaymentController do
  use SnitchApiWeb, :controller
  alias Snitch.Data.Model.GeneralConfiguration, as: GCModel
  alias SnitchApi.Payment.HostedPayment
  alias SnitchPayments
  alias SnitchPayments.Gateway.{PayuBiz, RazorPay, Stripe}
  alias SnitchPayments.Provider

  plug(SnitchApiWeb.Plug.DataToAttributes)
  action_fallback(SnitchApiWeb.FallbackController)

  @base_url Application.fetch_env!(:snitch_api, :hosted_payment_url)

  def payubiz_request_url(conn, params) do
    {params, url} = payubiz_params_setup(params)
    params = Keyword.put(params, :hash, generate_payubiz_hash(params))

    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    {:ok, response} = HTTPoison.post(url, {:form, params}, headers, follow_redirect: false)

    case List.keyfind(response.headers, "Location", 0) do
      nil ->
        message = Floki.find(response.body, "p") |> Floki.text()
        render(conn, "payubiz-url.json-api", error: message)

      {_, location} ->
        render(conn, "payubiz-url.json-api", url: location)
    end
  end

  def stripe_request_params(conn, %{"id" => id}) do
    id = String.to_integer(id)
    preferences = HostedPayment.get_payment_preferences(id)
    key = preferences[:credentials]["publishable_key"]
    render(conn, "stripe.json-api", publishable_key: key)
  end

  def stripe_purchase(conn, params) do
    ## TODO get the currency set for store here and use that.
    currency = GCModel.fetch_currency()
    amount = Money.new!(currency, params["amount"])
    preferences = HostedPayment.get_payment_preferences(params["payment_method_id"])
    secret = preferences[:credentials]["secret_key"]
    request_params = stripe_params_setup(params)
    token = params["token"]

    case Stripe.purchase(token, secret, amount, request_params) do
      %{"error" => _error} = response ->
        response = updated_stripe_response(response, params)
        non_hpm_purchase_response("error", conn, response)

      response ->
        response = updated_stripe_response(response, params)
        non_hpm_purchase_response("success", conn, response)
    end
  end

  def rzpay_request_params(conn, %{"id" => id}) do
    id = String.to_integer(id)
    preferences = HostedPayment.get_payment_preferences(id)
    key = preferences[:credentials]["key_id"]
    render(conn, "rzpay.json-api", key_id: key)
  end

  def rzpay_purchase(conn, params) do
    # At present we are providing support only for INR, may need to change
    # later.
    amount = Money.new!(:INR, params["amount"])
    preferences = HostedPayment.get_payment_preferences(params["payment_method_id"])
    key_id = preferences[:credentials]["key_id"]
    key_secret = preferences[:credentials]["key_secret"]

    token = params["token"]

    request_params = %{amount: amount, payment_id: token}

    case RazorPay.purchase(request_params, key_id, key_secret) do
      {:error, response} ->
        response = updated_rzpay_response(response, params)
        non_hpm_purchase_response("error", conn, response)

      {:ok, response} ->
        response = updated_rzpay_response(response, params)
        non_hpm_purchase_response("success", conn, response)
    end
  end

  def payment_success(conn, params) do
    response = SnitchPayments.data_parser(params)
    url = Application.fetch_env!(:snitch_api, :frontend_checkout_url)

    with {:ok, order} <- HostedPayment.payment_order_context(response) do
      address = url <> "order-success?orderReferance=#{order.number}"

      redirect(
        conn,
        external: address
      )
    else
      {:error, message} ->
        redirect(
          conn,
          external: url <> "order-failed?reason=#{message}"
        )
    end
  end

  def payment_error(conn, params) do
    response = SnitchPayments.data_parser(params)
    url = Application.fetch_env!(:snitch_api, :frontend_checkout_url)

    with {:ok, order} <- HostedPayment.payment_order_context(response) do
      redirect(conn,
        external:
          url <> "order-failed?orderReferance=#{order.number}&reason=#{response.error_reason}"
      )
    else
      {:error, _} ->
        redirect(conn, external: url <> "?error=error")
    end
  end

  ############# Private Functions ###############

  defp non_hpm_purchase_response("success", conn, params) do
    response = SnitchPayments.data_parser(params)

    with {:ok, order} <- HostedPayment.payment_order_context(response) do
      render(conn, "payment_success.json-api", order: order)
    end
  end

  defp non_hpm_purchase_response("error", conn, params) do
    response = SnitchPayments.data_parser(params)

    with {:ok, order} <- HostedPayment.payment_order_context(response) do
      render(conn, "payment_failure.json-api",
        order: order,
        reason: response.error_reason
      )
    end
  end

  defp stripe_params_setup(params) do
    address = params["address"]
    email = params["email"]
    [receipt_email: email, address: address]
  end

  defp updated_stripe_response(response, params) do
    source = Provider.provider(:stripe)

    response
    |> Map.put("order_id", params["order_id"])
    |> Map.put("payment_id", params["payment_id"])
    |> Map.put("payment_source", source)
  end

  defp updated_rzpay_response(response, params) do
    source = Provider.provider(:rzpay)

    response
    |> Map.put("order_id", params["order_id"])
    |> Map.put("payment_id", params["payment_id"])
    |> Map.put("payment_source", source)
  end

  defp payubiz_params_setup(params) do
    source = Provider.provider(:payubiz)
    query_string = "?order_id=#{params["order_id"]}&payment_id=#{params["payment_id"]}"
    surl = @base_url <> "#{source}/success" <> query_string
    furl = @base_url <> "#{source}/success" <> query_string
    preferences = HostedPayment.get_payment_preferences(params["payment_method_id"])
    urls = PayuBiz.get_url()

    url =
      case preferences[:live_mode] do
        true ->
          Map.get(urls, :live_url)

        false ->
          Map.get(urls, :test_url)
      end

    key = preferences[:credentials]["merchant_key"]
    salt = preferences[:credentials]["salt"]

    params =
      params
      |> Map.put("surl", surl)
      |> Map.put("furl", furl)
      |> Map.put("key", key)
      |> Map.put("salt", salt)
      |> create_payubiz_params()

    {params, url}
  end

  defp create_payubiz_params(params) do
    [
      key: params["key"],
      txnid: params["order_number"],
      amount: params["amount"],
      productinfo: params["product_info"],
      firstname: params["first_name"],
      email: params["email"],
      surl: params["surl"],
      furl: params["furl"],
      salt: params["salt"]
    ]
  end

  defp generate_payubiz_hash(params) do
    hash_string =
      "#{params[:key]}|#{params[:txnid]}|#{params[:amount]}|#{params[:productinfo]}|#{
        params[:firstname]
      }|#{params[:email]}#{String.duplicate("|", 11)}#{params[:salt]}"

    Base.encode16(:crypto.hash(:sha512, hash_string), case: :lower)
  end
end
