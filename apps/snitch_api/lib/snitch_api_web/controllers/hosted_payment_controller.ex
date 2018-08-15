defmodule SnitchApiWeb.HostedPaymentController do
  use SnitchApiWeb, :controller
  alias SnitchApi.Payment.HostedPayment
  alias SnitchPayments
  alias SnitchPayments.Gateway.PayuBiz
  alias SnitchPayments.Provider

  plug(SnitchApiWeb.Plug.DataToAttributes)
  action_fallback(SnitchApiWeb.FallbackController)

  @base_url "http://localhost:3000/api/v1/hosted-payment/"
  @frontend_url ""

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

  def payment_success(conn, params) do
    response = SnitchPayments.data_parser(params)

    with {:ok, _, _} <- HostedPayment.payment_order_context(response) do
      redirect(conn, external: @frontend_url <> "?info=payment_success")
    else
      {:error, _} ->
        redirect(conn, external: @frontend_url <> "?error=payment_failed")
    end
  end

  def payment_error(conn, params) do
    response = SnitchPayments.data_parser(params)

    with {:ok, _, _} <- HostedPayment.payment_order_context(response) do
      redirect(conn, external: @frontend_url <> "?info=payment_failed")
    else
      {:error, _} ->
        redirect(conn, external: @frontend_url <> "?error=error")
    end
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
      txnid: params["order_id"],
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
