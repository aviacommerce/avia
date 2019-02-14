defmodule AdminAppWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use AdminAppWeb, :controller
      use AdminAppWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, log: false, namespace: AdminAppWeb
      import Plug.Conn
      import AdminAppWeb.Router.Helpers
      import AdminAppWeb.Gettext

      def action(conn, _) do
        args = [conn, conn.params]
        controller = conn.private.phoenix_controller
        action = conn.private.phoenix_action
        actions = controller.module_info(:exports) |> Keyword.keys()

        case Enum.member?(actions, action) do
          true ->
            apply(__MODULE__, action_name(conn), args)

          false ->
            conn |> render(AdminAppWeb.ErrorView, "404.html") |> halt
        end
      end
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/admin_app_web/templates",
        namespace: AdminAppWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import AdminAppWeb.Router.Helpers
      import AdminAppWeb.ErrorHelpers
      import AdminAppWeb.Gettext
      import AdminAppWeb.InputHelpers
      import AdminAppWeb.PaginationHelpers
      import AdminAppWeb.DataHelpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel, log_join: false, log_handle_in: false
      import AdminAppWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
