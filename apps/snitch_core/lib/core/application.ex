defmodule Snitch.Application do
  @moduledoc """
  The Snitch Application Service.

  The Snitch system business domain lives in this application.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link(
      [
        supervisor(Snitch.Repo, []),
        supervisor(Snitch.Service.Analytics.Supervisor, [])
      ],
      strategy: :one_for_one,
      name: Snitch.Supervisor
    )
  end
end
