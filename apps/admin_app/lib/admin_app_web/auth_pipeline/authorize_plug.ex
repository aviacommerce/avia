defmodule AdminAppWeb.AuthorizePlug do
  @moduledoc """
  A plug that ensures a `user` is authorised to access a
  particular controller function.

  Users are allowed to access a particular route based
  on their `role` and `permissions` associated with those
  roles. To see how permissions are configured for controller
  functions, checkout `priv/role_manifest.yaml`.

  This plug needs to be setup as a part of the controller plug
  pipeline. For more info on controller plug pipeline
  see [this](https://hexdocs.pm/phoenix/Phoenix.Controller.html).

  This plug expects a guard to be used, to run for a particular
  set of functions.

  ## Example
    defmodule defmodule AdminAppWeb.OrderController do
      plug AdminAppWeb.AuthorizePlug when action in [:new, :create]
    end
  """

  import Plug.Conn
  import Phoenix.Controller
  import AdminAppWeb.Router.Helpers
  alias AdminAppWeb.RoleHelper

  def init(_params) do
  end

  def call(conn, _opts) do
    controller = to_string(conn.private.phoenix_controller)
    action = to_string(conn.private.phoenix_action)
    user_permissions = load_permissions(conn)
    user_role = load_role(conn)

    if RoleHelper.is_accessible?(user_role, user_permissions, controller, action) do
      conn
    else
      conn
      |> put_flash(:error, "you are unauthorized to access this!")
      |> redirect(to: session_path(conn, :new))
      |> halt()
    end
  end

  defp load_role(conn) do
    conn.private.guardian_default_resource.role.name
  end

  defp load_permissions(conn) do
    user = conn.private.guardian_default_resource
    Enum.map(user.role.permissions, & &1.code)
  end
end
