defmodule SnitchApiWeb.Service.Analytics do
  @moduledoc false
  alias Snitch.Service.Analytics.Domain, as: EventTracker

  def track(conn, params) do
    current_user = conn.assigns[:current_user]
    create_event(current_user, params)
  end

  defp create_event(nil, _), do: :ok

  defp create_event(user, params) do
    params = Map.put(params, :user_id, user.id)
    EventTracker.create_event(params)
  end
end
