defmodule AdminAppWeb.GeneralSettingsController do
  use AdminAppWeb, :controller

  alias Snitch.Data.Model.GeneralConfiguration, as: GCModel
  alias Snitch.Data.Schema.GeneralConfiguration, as: GCSchema
  alias Snitch.Core.Tools.MultiTenancy.Repo

  def index(conn, _params) do
    general_configuration =
      GCModel.list_general_configuration() |> List.first() |> Repo.preload(:image)

    render(conn, "index.html", general_configuration: general_configuration)
  end

  def new(conn, _params) do
    changeset = GCModel.build_general_configuration()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"settings" => params}) do
    case GCModel.create(params) do
      {:ok, general_configuration} ->
        general_configuration =
          GCModel.list_general_configuration() |> List.first() |> Repo.preload(:image)

        conn
        |> put_flash(:info, "General configuration created successfully")
        |> render("index.html", general_configuration: general_configuration)

      {:error, changeset} ->
        conn
        |> render("new.html", changeset: %{changeset | action: :insert})
    end
  end

  def edit(conn, %{"id" => id}) do
    general_configuration = GCModel.get_general_configuration(id) |> Repo.preload(:image)

    case general_configuration do
      nil ->
        handle_nil_response(conn)

      _ ->
        changeset = GCSchema.update_changeset(general_configuration, %{})

        render(
          conn,
          "edit.html",
          changeset: changeset,
          general_configuration: general_configuration
        )
    end
  end

  def update(conn, %{"id" => id, "settings" => params}) do
    general_configuration = GCModel.get_general_configuration(id) |> Repo.preload(:image)

    case general_configuration do
      nil ->
        handle_nil_response(conn)

      _ ->
        params =
          params
          |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)

        case GCModel.update(general_configuration, params) do
          {:ok, general_configuration} ->
            conn
            |> put_flash(:info, "General configuration updated successfully")
            |> redirect(to: general_settings_path(conn, :index))

          {:error, changeset} ->
            conn
            |> render(
              "edit.html",
              changeset: %{changeset | action: :update},
              general_configuration: general_configuration
            )
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    changeset = GCModel.build_general_configuration()

    case GCModel.delete_general_configuration(id) do
      {:ok, general_configuration} ->
        conn
        |> put_flash(:info, "Configuration deleted successfully")
        |> render("new.html", changeset: changeset)

      {:error, _} ->
        conn
        |> render("new.html", changeset: changeset)
    end
  end

  defp handle_nil_response(conn) do
    conn
    |> put_flash(:error, "General configuration does not exist")
    |> redirect(to: general_settings_path(conn, :index))
  end
end
