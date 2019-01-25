defmodule AdminAppWeb.Tax.TaxConfigController do
  @moduledoc false
  use AdminAppWeb, :controller
  alias Snitch.Data.Model.TaxConfig
  alias Snitch.Data.Schema.TaxConfig, as: TaxConfigSchema

  plug(:put_layout, {AdminAppWeb.Tax.TaxConfigView, "tax_layout.html"})

  def index(conn, _params) do
    tax_config = TaxConfig.get_default()
    changeset = TaxConfigSchema.update_changeset(tax_config, %{})
    render(conn, "edit.html", changeset: changeset, tax_config: tax_config)
  end

  def update(conn, %{"id" => id, "tax_config" => params}) do
    config = id |> TaxConfig.get() |> get(conn)

    with {:ok, _config} <- TaxConfig.update(config, params) do
      redirect(conn, to: tax_config_path(conn, :index))
    else
      {:error, changeset} ->
        render(conn, "edit.html",
          changeset: %{changeset | action: :update},
          tax_config: config
        )
    end
  end

  defp get({:ok, config}, _conn), do: config

  defp get({:error, message}, conn) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: tax_config_path(conn, :index))
  end
end
