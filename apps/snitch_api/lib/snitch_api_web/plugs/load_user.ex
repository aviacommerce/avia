defmodule SnitchApiWeb.Plug.LoadUser do
  import Plug.Conn
  alias SnitchApi.Guardian

  def init(opts), do: opts

  def call(conn, _opts) do
    user = Guardian.Plug.current_resource(conn)
    assign(conn, :current_user, user)
  end
end
