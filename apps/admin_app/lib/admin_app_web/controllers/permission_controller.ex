defmodule AdminAppWeb.PermissionController do
  use AdminAppWeb, :controller
  alias Snitch.Data.Model.Permission
  alias Snitch.Data.Schema.Permission, as: PermissionSchema

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
      nil ->
        conn
        |> put_flash(:error, "Sorry not found")
        |> redirect(to: permission_path(conn, :index))

      permission ->
        changeset = PermissionSchema.update_changeset(permission, %{})
        render(conn, "edit.html", changeset: changeset, permission: permission)
    end
  end

  def update(conn, %{"id" => id, "permission" => permission}) do
    id = String.to_integer(id)
    params = parse_permission_params(permission)
    permission = Permission.get(id)

    case Permission.update(params, permission) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "permission updated successfully!")
        |> redirect(to: permission_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Sorry some error occured!!")
        |> render("edit.html", changeset: %{changeset | action: :update}, permission: permission)
    end
  end

  def delete(conn, %{"id" => id}) do
    id = String.to_integer(id)

    case Permission.delete(id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Permission deleted successfully!")
        |> redirect(to: permission_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:error, "Permission not found!")
        |> redirect(to: permission_path(conn, :index))
    end
  end

  ################ Private Functions ###############
  defp parse_permission_params(permission) do
    %{
      code: permission["code"],
      description: permission["description"]
    }
  end
end
