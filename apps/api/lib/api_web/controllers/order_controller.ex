defmodule ApiWeb.OrderController do
  use ApiWeb, :controller

  alias Snitch.Data.Model.{Order, User}
  alias Snitch.Repo
  alias ApiWeb.FallbackController, as: Fallback

  def current(conn, _params) do
    order =
      Order.get_all()
      |> List.first()
      |> Repo.preload(line_items: [variant: :images], shipping_address: [], billing_address: [])

    render(conn, "order.json", order: order)
  end

  def create(conn, %{"line_items" => line_items} = params) do
    do_create(conn, params, line_items)
  end

  def create(conn, params) do
    do_create(conn, params, [])
  end

  defp do_create(conn, params, line_items) do
    user = get_user()
    slug = unique_id()

    params
    |> Map.put(:user_id, user.id)
    |> Map.put(:slug, slug)
    |> Order.create(line_items)
    |> case do
      {:ok, order} ->
        render(conn, "order.json", order: order)

      {:error, _} = error ->
        Fallback.call(conn, error)
    end
  end

  defp get_user do
    List.first(User.get_all())
  end

  defp unique_id do
    UUID.uuid1()
  end
end
