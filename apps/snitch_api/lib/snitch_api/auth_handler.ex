defmodule SnitchApi.AuthErrorHandler do
  import Plug.Conn

  def auth_error(conn, {type, _reason}, _opts) do
    body = Poison.encode!(%{error: to_string(type)})
    send_resp(conn, 403, body)
  end
end
