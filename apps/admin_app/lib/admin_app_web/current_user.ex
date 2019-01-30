defmodule Auth.CurrentUser do
  @moduledoc """
  Plug to fetch the current user from Guardian Plug and set it as 
  current user session variable
  """
  import Plug.Conn
  import Guardian.Plug
  def init(opts), do: opts

  def call(conn, _opts) do
    current_user = current_resource(conn)
    assign(conn, :current_user, current_user)
  end
end
