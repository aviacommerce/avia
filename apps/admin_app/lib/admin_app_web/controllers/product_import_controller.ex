defmodule AdminAppWeb.ProductImportController do
  use AdminAppWeb, :controller

  alias Snitch.Data.Model.StoreProps
  alias Avia.Etsy.Importer

  def import_etsy(conn, params) do
    with {:ok, consumer_key, cosumer_secret} <- Importer.get_app_keys(),
         {:ok, body} <-
           Importer.authorize_app(
             consumer_key,
             cosumer_secret,
             @request_token_url,
             Importer.get_callback_url()
           ),
         {:ok, props} <- Importer.save_oauth_secret(body["oauth_token_secret"]) do
      redirect(conn, external: body["login_url"])
    else
      _ ->
        conn
        |> put_flash(:error, "Failed to authorize Avia app")
        |> redirect(to: product_path(conn, :index))
    end
  end

  def oauth_callback(conn, %{"oauth_token" => token, "oauth_verifier" => verifier}) do
    with {:ok, consumer_key, consumer_secret} <- Importer.get_app_keys(),
         {:ok, prop} <- StoreProps.get(@oauth_secret),
         {:ok, body} <-
           Importer.get_access_token(consumer_key, consumer_secret, token, prop.value, verifier),
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
    Honeydew.async({:run, [:etsy_store]}, :etsy_import_queue)

    render(conn, "import.html")
  end
end
