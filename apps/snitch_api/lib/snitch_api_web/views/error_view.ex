defmodule SnitchApiWeb.ErrorView do
  use SnitchApiWeb, :view

  def render("404.json-api", _assigns) do
    %{errors: %{detail: "Page not found"}}
  end

  def render("unauthorized.json-api", _assigns) do
    %{errors: %{detail: "un_authorized"}}
  end

  def render("no_credentials.json-api", _assigns) do
    %{errors: %{detail: "no login credentials"}}
  end

  def render("500.json-api", _assigns) do
    %{errors: %{detail: "Internal server error"}}
  end

  def render("505.json-api", _assigns) do
    %{errors: %{detail: "Internal server error"}}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render("500.json", assigns)
  end
end
