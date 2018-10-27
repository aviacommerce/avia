defmodule AdminAppWeb.PromotionView do
  use AdminAppWeb, :view


  def get_date(conn, key_list) do
    date = get_in(conn.params, key_list)
    date || Date.utc_today()
  end
end
