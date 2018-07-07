defmodule SnitchApiWeb.UserController do
  use SnitchApiWeb, :controller

  alias SnitchApi.Accounts
  alias Snitch.Data.Schema.User

  action_fallback(SnitchApiWeb.FallbackController)

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json-api", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show.json-api", data: user)
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.token_sign_in(email, password) do
      {:ok, token, _claims} ->
        render(conn, "token.json-api", data: token)

      _ ->
        {:error, :unauthorized}
    end
  end

  def login(conn, _params) do
    {:error, :no_credentials}
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json-api", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json-api", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
