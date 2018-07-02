defmodule AdminAppWeb.RoleController do
  use AdminAppWeb, :controller
  alias Snitch.Data.Model.Role
  alias Snitch.Data.Schema.Role, as: RoleSchema

  def index(conn, _params) do
    roles = Role.get_all()
    render(conn, "index.html", roles: roles)
  end

  def create(conn, %{"role" => role}) do
    params = parse_role_params(role)

    case Role.create(params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Role created!!")
        |> redirect(to: role_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Sorry there were some errors !!")
        |> render("new.html", changeset: %{changeset | action: :insert})
    end
  end

  def new(conn, _params) do
    changeset = RoleSchema.create_changeset(%RoleSchema{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def edit(conn, %{"id" => id}) do
    case Role.get(String.to_integer(id)) do
      nil ->
        conn
        |> put_flash(:error, "Sorry role not found")
        |> render("index.html")

      role ->
        changeset = RoleSchema.update_changeset(role, %{})
        render(conn, "edit.html", changeset: changeset, role: role)
    end
  end

  def update(conn, %{"id" => id, "role" => role}) do
    id = String.to_integer(id)
    params = parse_role_params(role)
    role = Role.get(id)

    case Role.update(params, role) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Role updated successfully")
        |> redirect(to: role_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Sorry some error occured!!")
        |> render("edit.html", changeset: %{changeset | action: :update}, role: role)
    end
  end

  def delete(conn, %{"id" => id}) do
    id = String.to_integer(id)

    case Role.delete(id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Role deleted successfully!!")
        |> redirect(to: role_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:error, "role not found")
        |> redirect(to: role_path(conn, :index))
    end
  end

  ################ Private Functions ###############
  defp parse_role_params(role) do
    %{
      name: role["name"],
      description: role["description"]
    }
  end
end
