defmodule SnitchApiWeb.UserController do
  use SnitchApiWeb, :controller

  alias Snitch.Data.Schema.User
  alias SnitchApi.Accounts
  alias SnitchApi.Guardian
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Model.User, as: UserModel

  plug(SnitchApiWeb.Plug.DataToAttributes)
  plug(SnitchApiWeb.Plug.LoadUser)

  action_fallback(SnitchApiWeb.FallbackController)

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json-api", users: users)
  end

  def create(conn, params) do
    with {:ok, %User{} = user} <- Accounts.create_user(params) do
      conn
      |> put_status(200)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show.json-api", data: user)
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.token_sign_in(email, password) do
      {:ok, token, _claims} ->
        {:ok, user} = UserModel.get(%{email: email})
        render(conn, "token.json-api", data: token, user: user)

      _ ->
        {:error, :unauthorized}
    end
  end

  def login(_conn, _params) do
    {:error, :no_credentials}
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json-api", data: user)
  end

  def logout(conn, _params) do
    conn
    |> Guardian.Plug.sign_out()
    |> put_status(204)
    |> render("logout.json-api", data: "logged out")
  end

  def current_user(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    render(conn, "current_user.json-api", data: user)
  end

  def authenticated(conn, _params) do
    user = conn.assigns[:current_user]
    render(conn, "show.json-api", data: user)
  end
end
