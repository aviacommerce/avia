defmodule SnitchApi.UserActivity do
  @moduledoc """
  Exposes functions related to user activity.
  """

  alias Snitch.Service.Analytics.Domain, as: Analytics
  alias Snitch.Data.Model.Product
  alias Snitch.Repo
  alias Snitch.Data.Schema.User

  @product_detail_event "product_detail"

  @doc """
  Returns all the recently viewed products by a
  user.
  """
  @spec recently_viewed_products(User.t()) :: [Product.t()]
  def recently_viewed_products(user) do
    properties = Analytics.user_event_property(user.id, @product_detail_event)

    product_ids =
      Enum.map(properties, fn %{"product_id" => id} ->
        id
      end)

    product_ids
    |> Product.get_by_id_list()
    |> Repo.all()
  end

  @doc """
  Creates a product detail event for the supplied `user` with
  the `params`.
  """
  @spec product_detail_event(User.t(), map) :: :ok
  def product_detail_event(user, params) do
    event_params = %{
      user_id: user.id,
      name: @product_detail_event,
      properties: params
    }

    Analytics.create_event(event_params)
  end
end
