defmodule AdminAppWeb.UserController do
  use AdminAppWeb, :controller
  alias Snitch.Data.Schema.User
  alias Snitch.Data.Model.User, as: UserModel
  alias Snitch.Domain.Account
  alias Snitch.Core.Tools.MultiTenancy.Repo

  def index(conn, _params) do
    users = UserModel.get_all()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = User.create_changeset(%User{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user}) do
    params = parse_user_params(user)

    case Account.register(params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Account created!")
        |> redirect(to: user_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Sorry there were some errors!")
        |> render("new.html", changeset: %{changeset | action: :insert})
    end
  end

  def edit(conn, %{"id" => id}) do
    case UserModel.get(String.to_integer(id)) do
      {:error, _} ->
        conn
        |> put_flash(:error, "Sorry user not found")
        |> render("index.html")

      {:ok, user} ->
        changeset = User.update_changeset(user, %{})
        render(conn, "edit.html", changeset: changeset, user: user)
    end
  end

  def update(conn, %{"id" => id, "user" => user}) do
    id = String.to_integer(id)
    params = parse_user_params(user)

    {:ok, user} = UserModel.get(id)
    user = user |> Repo.preload(:role)

    case UserModel.update(params, user) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "User updated successfully")
        |> redirect(to: user_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Sorry some error occured!")
        |> render("edit.html", changeset: %{changeset | action: :update}, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    id = String.to_integer(id)

    case UserModel.delete(id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "User deleted successfully!")
        |> redirect(to: user_path(conn, :index))

      {:error, msg} ->
        conn
        |> put_flash(:error, msg)
        |> redirect(to: user_path(conn, :index))
    end
  end

  ########## Private Functions ###################

  defp parse_user_params(user) do
    %{
      first_name: user["first_name"],
      last_name: user["last_name"],
      email: user["email"],
      password: user["password"],
      password_confirmation: user["password_confirmation"],
      role_id: String.to_integer(user["role_id"])
    }
  end
end
