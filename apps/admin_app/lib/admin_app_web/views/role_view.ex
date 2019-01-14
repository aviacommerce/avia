defmodule AdminAppWeb.RoleView do
  use AdminAppWeb, :view

  def selected_permissions(permissions) do
    Enum.map(permissions, fn permission -> permission.id end)
  end

  def is_default_role(name) do
    name in ["admin", "user"]
  end
end
