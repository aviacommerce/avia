defmodule ApiWeb.ErrorView do
  use ApiWeb, :view

  def render("400.json", assigns) do
    %{
      errors: %{
        detail: assigns[:detail] || "Hmm, does not look good.. and you can't do nothing about it."
      }
    }
  end

  def render("404.json", _assigns) do
    %{errors: %{detail: "Page not found"}}
  end

  def render("500.json", _assigns) do
    %{errors: %{detail: "Internal server error"}}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render("500.json", assigns)
  end
end
