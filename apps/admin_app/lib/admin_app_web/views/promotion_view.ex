defmodule AdminAppWeb.PromotionView do
  use AdminAppWeb, :view

  alias Snitch.Data.Model

  def get_date(conn, key_list) do
    date = get_in(conn.params, key_list)
    date || Date.utc_today()
  end

  def get_module_list() do
    # Model.Promotion.load_promotion_manifest()
    %{
      "order total" => "Elixir.Snitch.Data.Schema.PrmotionRule.OrderTotal",
      "product" => "Elixir.Snitch.Data.Schema.PrmotionRule.Product"
    }

    # []
  end
end
