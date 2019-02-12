defmodule AdminAppWeb.LayoutView do
  use AdminAppWeb, :view
  alias AdminAppWeb.Guardian
  alias Snitch.Data.Schema.GeneralConfiguration, as: GC
  alias Snitch.Data.Schema.Taxonomy
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias AdminAppWeb.Helpers

  @doc """
  Generates name for the JavaScript view we want to use
  in this combination of view/template.
  """
  def js_view_name(conn, view_template) do
    [view_name(conn), template_name(view_template)]
    |> Enum.reverse()
    |> List.insert_at(0, "View")
    |> Enum.reverse()
    |> Enum.join("")
  end

  # Takes the resource name of the view module and removes the
  # the ending *_view* string.
  defp view_name(conn) do
    conn
    |> view_module
    |> Phoenix.Naming.resource_name()
    |> String.replace("_view", "")
    |> Macro.camelize()
  end

  # Removes the extension from the template and returns
  # just the name.
  defp template_name(template) when is_binary(template) do
    template
    |> String.split(".")
    |> Enum.at(0)
    |> Macro.camelize()
  end

  def check_general_settings do
    case Repo.one(GC) do
      nil -> false
      _ -> true
    end
  end

  def get_default_taxonomy() do
    Repo.all(Taxonomy) |> List.first()
  end

  def get_user_name(conn) do
    user = conn.private.guardian_default_resource
    "#{user.first_name} #{user.last_name}"
  end

  def render_layout(layout, assigns, do: content) do
    render(layout, Map.put(assigns, :inner_layout, content))
  end
end
