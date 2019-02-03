defmodule AdminApp.Order.SearchContext do
  import Ecto.Query
  alias Snitch.Data.Schema.{Order, User}
  alias Snitch.Core.Tools.MultiTenancy.Repo

  def search_orders(%{"term" => term} = payload) do
    state = get_order_state(term)

    user_ids =
      from(user in User,
        where:
          ilike(user.first_name, ^"%#{term}%") or ilike(user.last_name, ^"%#{term}%") or
            ilike(user.email, ^"%#{term}%"),
        select: user.id
      )
      |> Repo.all()

    query =
      get_orders_with_state(user_ids, term, state)
      |> preload([:user, [packages: [:shipping_method, :items]], [line_items: :product]])
      |> Repo.all()
  end

  def search_orders(%{
        "start_date" => start_date,
        "end_date" => end_date
      }) do
    start_date = format_date(start_date)
    end_date = format_date(end_date)

    from(o in Order, where: o.inserted_at >= ^start_date and o.inserted_at <= ^end_date)
    |> preload([:user, [packages: [:shipping_method, :items]], [line_items: :product]])
    |> Repo.all()
  end

  defp format_date(date) do
    NaiveDateTime.from_iso8601!("#{date} 00:00:00")
  end

  defp get_order_state(term) do
    case OrderStateEnum.valid_value?(term) do
      true ->
        term

      false ->
        "invalid"
    end
  end

  defp get_orders_with_state(user_ids, term, "invalid") do
    Order
    |> where(
      [o],
      o.user_id in ^user_ids or ilike(o.number, ^"%#{term}%")
    )
  end

  defp get_orders_with_state(user_ids, term, valid_state) do
    Order
    |> where(
      [o],
      o.user_id in ^user_ids or ilike(o.number, ^"%#{term}%") or o.state == ^valid_state
    )
  end
end
