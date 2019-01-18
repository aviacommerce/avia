defmodule AdminAppWeb.PermissionController do
  use AdminAppWeb, :controller
  alias Snitch.Data.Model.Permission
  alias Snitch.Data.Schema.Permission, as: PermissionSchema
  alias AdminAppWeb.Helpers

  def index(conn, _params) do
    permissions = Permission.get_all()
    render(conn, "index.html", permissions: permissions)
  end

  def create(conn, %{"permission" => permission}) do
    params = parse_permission_params(permission)

    case Permission.create(params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Permission created!")
        |> redirect(to: permission_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Sorry there were some errors !")
        |> render("new.html", changeset: %{changeset | action: :insert})
    end
  end

  def new(conn, _params) do
    changeset = PermissionSchema.create_changeset(%PermissionSchema{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def edit(conn, %{"id" => id}) do
    case Permission.get(String.to_integer(id)) do
      {:error, msg} ->
        conn
        |> put_flash(:error, "Sorry not found")
        |> redirect(to: permission_path(conn, :index))

      {:ok, permission} ->
        changeset = PermissionSchema.update_changeset(permission, %{})
        render(conn, "edit.html", changeset: changeset, permission: permission)
    end
  end

  def update(conn, %{"id" => id, "permission" => permission}) do
    id = String.to_integer(id)
    params = parse_permission_params(permission)
    {:ok, permission} = Permission.get(id)

    case Permission.update(params, permission) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "permission updated successfully!")
        |> redirect(to: permission_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Sorry some error occured!")
        |> render("edit.html", changeset: %{changeset | action: :update}, permission: permission)
    end
  end

  def delete(conn, %{"id" => id}) do
    id = String.to_integer(id)

    conn =
      case Permission.delete(id) do
        {:ok, _} ->
          put_flash(conn, :info, "Permission deleted successfully!")

        {:error, :not_found} ->
          put_flash(conn, :error, "Permission not found!")

        {:error, changeset} ->
          errors = Helpers.extract_changeset_errors(changeset)
          error = stringify_error(errors)
          put_flash(conn, :error, "Error! #{error}")
      end

    redirect(conn, to: permission_path(conn, :index))
  end

  ################ Private Functions ###############
  defp parse_permission_params(permission) do
    %{
      code: permission["code"],
      description: permission["description"]
    }
  end

  defp stringify_error(error_map) do
    Enum.reduce(error_map, "", fn {key, value}, acc ->
      value = Enum.join(value, ",")
      "#{acc} #{key}: #{value}"
    end)
  end
end
