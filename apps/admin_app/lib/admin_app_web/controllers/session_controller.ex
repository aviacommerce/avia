defmodule AdminAppWeb.SessionController do
  use AdminAppWeb, :controller
  use Params
  import AdminAppWeb.Helpers
  alias AdminAppWeb.{Email, Endpoint, Guardian.Plug}
  alias Phoenix.Token
  alias Snitch.Domain.Account
  alias Snitch.Data.Model.User, as: UserModel
  alias Snitch.Data.Schema.User, as: UserSchema

  @password_reset_salt Application.get_env(:admin_app, AdminAppWeb.Endpoint)[:password_reset_salt]

  defparams(
    signin_params(%{
      email!: :string,
      password!: :string
    })
  )

  def new(conn, _params) do
    changeset = signin_params(%{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"session" => session}) do
    changeset = signin_params(session)
    verify_session(extract_changeset_data(changeset), conn)
  end

  def edit(conn, %{"id" => id}) do
    render(conn, "edit_password.html", user_id: id)
  end

  def update(conn, %{"id" => id, "new_password" => password_params}) do
    {:ok, user} = UserModel.get(%{id: id})
    update_user = UserModel.update(password_params, user)
    update_password_result(update_user, conn)
  end

  def delete(conn, _params) do
    conn
    |> Plug.sign_out()
    |> redirect(to: session_path(conn, :new))
  end

  def password_reset(conn, _params) do
    render(conn, "password_reset.html")
  end

  def check_email(conn, %{"password_reset" => params}) do
    email = params["email"]
    {:ok, user} = UserModel.get(%{email: email})
    mail_verified_user(user, conn)
  end

  def verify(conn, params) do
    case verify_password_token(params["token"]) do
      {:ok, user_id} ->
        conn
        |> put_flash(:info, "You can now update your password")
        |> redirect(to: session_path(conn, :edit, user_id))

      {:error, _} ->
        conn
        |> put_flash(:error, "Password token expired, please try again")
        |> redirect(to: session_path(conn, :new))
    end
  end

  ############## private functions ###############

  defp verify_session({:ok, %{email: email, password: password}}, conn) do
    login(Account.authenticate(email, password), conn)
  end

  defp verify_session({:error, changeset}, conn) do
    conn
    |> put_flash(:error, "Sorry there were some errors !")
    |> render("new.html", changeset: %{changeset | action: :insert})
  end

  defp mail_verified_user(%UserSchema{} = user, conn) do
    token = tokenize(user)
    base_url = Endpoint.url()
    send_mail(token, user.email, base_url)
    update_user_with_token(token, user, conn)
  end

  defp mail_verified_user(nil, conn) do
    conn
    |> put_flash(:error, "Sorry, we don't know that email address. Try again?")
    |> redirect(to: session_path(conn, :new))
  end

  defp send_mail(token, mail, url) do
    Email.password_reset_mail(token, mail, url)
  end

  defp update_user_with_token(token, user, conn) do
    sent_at = DateTime.utc_now()

    password_reset_params = %{
      reset_password_token: token,
      reset_password_sent_at: sent_at
    }

    user =
      UserModel.update(
        password_reset_params,
        user
      )

    update_user_result(user, conn)
  end

  defp update_user_result({:ok, _}, conn) do
    conn
    |> put_flash(:info, "A password reset email has been sent you. Please check")
    |> redirect(to: session_path(conn, :new))
  end

  defp update_user_result({:error, _}, conn) do
    conn
    |> put_flash(:error, "Please try again")
    |> redirect(to: session_path(conn, :new))
  end

  defp login({:ok, %{role: %{name: "user"}}}, conn) do
    conn
    |> put_flash(:error, "Incorrect email/password")
    |> redirect(to: session_path(conn, :new))
  end

  defp login({:ok, user}, conn) do
    conn
    |> Plug.sign_in(user)
    |> put_flash(:info, "You are logged in!")
    |> redirect(to: dashboard_path(conn, :index))
  end

  defp login({:error, _}, conn) do
    conn
    |> put_flash(:error, "Incorrect email/password")
    |> redirect(to: session_path(conn, :new))
  end

  defp tokenize(%UserSchema{id: user_id}) do
    Token.sign(Endpoint, @password_reset_salt, user_id)
  end

  defp verify_password_token(token) do
    max_age = Application.get_env(:admin_app, AdminAppWeb.Endpoint)[:token_maximum_age]
    max_age_int = String.to_integer(max_age)

    Token.verify(
      Endpoint,
      @password_reset_salt,
      token,
      max_age: max_age_int
    )
  end

  defp update_password_result({:ok, _}, conn) do
    conn
    |> put_flash(:info, "Password updated successfully!")
    |> redirect(to: session_path(conn, :new))
  end

  defp update_password_result({:error, _}, conn) do
    conn
    |> put_flash(:error, "Error occured")
    |> redirect(to: session_path(conn, :new))
  end
end
