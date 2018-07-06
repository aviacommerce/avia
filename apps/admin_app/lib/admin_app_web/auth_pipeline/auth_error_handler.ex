defmodule AdminAppWeb.AuthErrorHandler do
  @moduledoc """
  Defines functions for handling authentication errors.
  """
  use AdminAppWeb, :controller

  def auth_error(conn, _, _opts) do
    conn
    |> put_flash(:error, "Sign in to continue")
    |> redirect(to: session_path(conn, :new))
  end
end
