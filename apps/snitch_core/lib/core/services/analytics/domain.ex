defmodule Snitch.Service.Analytics.Domain do
  @moduledoc """
  Domain functions for managing user analytics.
  """
  alias Hydrus

  @doc """
  Creates a job in the erlang queue for creating an
  event.
  """
  @spec create_event(map) :: :ok
  def create_event(params) do
    {:run, [params]}
    |> Honeydew.async(:analytics_queue, reply: true)

    :ok
  end

  @doc """
  Returns all the data created for a particular
  event type for a user.
  """
  @spec user_event_property(non_neg_integer, String.t()) :: [map]
  def user_event_property(user_id, name) do
    Hydrus.get_details(user_id, name)
  end
end
