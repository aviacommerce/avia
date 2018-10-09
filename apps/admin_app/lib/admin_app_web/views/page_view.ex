defmodule AdminAppWeb.PageView do
  use AdminAppWeb, :view

  def get_docs_url() do
    Application.get_env(:admin_app, AdminAppWeb.Endpoint)[:docs_url]
  end
end
