defmodule AdminAppWeb.ProductImportController do
  use AdminAppWeb, :controller

  @request_token_url "https://openapi.etsy.com/v2/oauth/request_token"
  @access_token_url "https://openapi.etsy.com/v2/oauth/access_token"

  @oauth_secret "etsy_oauth_secret"
  @access_token "etsy_access_token"
  @access_token_secret "etsy_access_token_secret"

  alias Snitch.Data.Model.StoreProps

  def import_etsy(conn, params) do
    with {:ok, consumer_key, cosumer_secret} <- get_app_keys(),
         {:ok, body} <-
           authorize_app(consumer_key, cosumer_secret, @request_token_url, get_callback_url()),
         {:ok, props} <- save_oauth_secret(body["oauth_token_secret"]) do
      redirect(conn, external: body["login_url"])
    else
      _ ->
        conn
        |> put_flash(:error, "Failed to authorize Avia app")
        |> redirect(to: product_path(conn, :index))
    end
  end

  def oauth_callback(conn, %{"oauth_token" => token, "oauth_verifier" => verifier}) do
    with {:ok, consumer_key, consumer_secret} <- get_app_keys(),
         {:ok, prop} <- StoreProps.get(@oauth_secret),
         {:ok, body} <-
           get_access_token(consumer_key, consumer_secret, token, prop.value, verifier),
         {:ok, access_token_prop} <- StoreProps.store(@access_token, body["oauth_token"]),
         {:ok, access_token_secret_prop} <-
           StoreProps.store(@access_token_secret, body["oauth_token_secret"]) do
      redirect(conn, to: "/product/import/etsy/progress")
    else
      _ ->
        conn
        |> put_flash(:error, "Failed to get acess token")
        |> redirect(to: product_path(conn, :index))
    end
  end

  def import_progress(conn, params) do
    render(conn, "import.html")
  end

  defp save_oauth_secret(oauth_secret) do
    StoreProps.store(@oauth_secret, oauth_secret)
  end

  def get_app_keys do
    with {:ok, consumer_key} <- get_key("AVIA_CONSUMER_KEY"),
         {:ok, consumer_secret} <- get_key("AVIA_CONSUMER_SECRET") do
      {:ok, consumer_key, consumer_secret}
    else
      {:error, :not_found} -> {:error, :invalid_key}
    end
  end

  def get_key(keyname) do
    case System.get_env(keyname) do
      nil -> {:error, :not_found}
      value -> {:ok, value}
    end
  end

  def get_access_token(
        consumer_key,
        consumer_secret,
        oauth_token,
        oauth_token_secret,
        oauth_verifier
      ) do
    creds =
      OAuther.credentials(
        consumer_key: consumer_key,
        consumer_secret: consumer_secret,
        token: oauth_token,
        token_secret: oauth_token_secret
      )

    params = OAuther.sign("get", @access_token_url, [{"oauth_verifier", oauth_verifier}], creds)

    {headers, req_params} = OAuther.header(params)

    case :hackney.get(@access_token_url, [headers], {:form, req_params}) do
      {:ok, 200, _, client_ref} ->
        body =
          client_ref
          |> get_response
          |> URI.decode_query()

        {:ok, body}

      _ ->
        {:error, :request_failed}
    end
  end

  def authorize_app(consumer_key, consumer_secret, request_token_url, callback_url) do
    creds = OAuther.credentials(consumer_key: consumer_key, consumer_secret: consumer_secret)

    params = OAuther.sign("get", request_token_url, [{"oauth_callback", callback_url}], creds)

    {headers, req_params} = OAuther.header(params)

    case :hackney.get(request_token_url, [headers], {:form, req_params}) do
      {:ok, 200, _, client_ref} ->
        body =
          client_ref
          |> get_response()
          |> URI.decode_query()

        {:ok, body}

      _ ->
        {:error, :request_failed}
    end
  end

  def get_callback_url() do
    AdminAppWeb.Endpoint.url() <> "/product/import/etsy/callback"
  end

  defp get_response(client_ref) do
    case :hackney.body(client_ref) do
      {:ok, body} -> body
    end
  end
end
