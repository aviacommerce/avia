defmodule AdminAppWeb.ProductImportController do
  use AdminAppWeb, :controller

  @request_token_url "https://openapi.etsy.com/v2/oauth/request_token"

  def import_etsy(conn, params) do
    with {:ok, consumer_key, cosumer_secret} <- get_app_keys(),
         {:ok, body} <-
           authorize_app(consumer_key, cosumer_secret, @request_token_url, get_callback_url()) do
      redirect(conn, external: body["login_url"])
    else
      _ ->
        conn
        |> put_flash(:error, "Failed to authorize Avia app")
        |> redirect(to: product_path(conn, :index))
    end
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
    "htttp://www.aviabird.com"
  end

  defp get_response(client_ref) do
    case :hackney.body(client_ref) do
      {:ok, body} -> body
    end
  end
end
