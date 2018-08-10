defmodule AdminAppWeb.TemplateApi.OptionTypeController do
  use AdminAppWeb, :controller

  alias AdminAppWeb.TemplateApi.OptionTypeView
  alias Snitch.Data.Model.VariationTheme
  import Phoenix.View, only: [render_to_string: 3]

  def index(conn, %{"theme_id" => theme_id} = params) do
    theme =
      VariationTheme.get(theme_id)
      |> Snitch.Repo.preload(:option_types)

    product_id = params["product_id"]

    html = render_to_string(OptionTypeView, "index.html", theme: theme, product_id: product_id)

    conn
    |> put_status(200)
    |> json(%{html: html})
  end
end
