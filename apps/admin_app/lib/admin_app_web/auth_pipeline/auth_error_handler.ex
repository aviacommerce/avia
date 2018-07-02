defmodule AdminAppWeb.AuthErrorHandler do
  use AdminAppWeb, :controller

  def auth_error(conn, params, _opts) do
    conn
    |> put_flash(:error, "Sign in to continue")
    |> redirect(to: session_path(conn, :new))
  end
end
