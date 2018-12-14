defmodule AdminAppWeb.GeneralSettingsController do
  use AdminAppWeb, :controller

  alias Snitch.Data.Model.GeneralConfiguration, as: GCModel
  alias Snitch.Data.Schema.GeneralConfiguration, as: GCSchema
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Model.Image

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
    params = handle_params(params)

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
    params = handle_params(params)
    general_configuration = GCModel.get_general_configuration(id) |> Repo.preload(:image)

    case general_configuration do
      nil ->
        handle_nil_response(conn)

      _ ->
        params

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

  defp handle_params(%{"image" => image} = params) do
    %{
      params
      | "image" => Image.handle_image_value(image)
    }
  end

  defp handle_params(params) do
    params
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
