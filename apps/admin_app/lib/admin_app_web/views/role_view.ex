defmodule AdminAppWeb.RoleView do
  use AdminAppWeb, :view

  def selected_permissions(permissions) do
    Enum.map(permissions, fn permission -> permission.id end)
  end
end
