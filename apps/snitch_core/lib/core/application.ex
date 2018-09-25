defmodule Snitch.Application do
  @moduledoc """
  The Snitch Application Service.

  The Snitch system business domain lives in this application.
  """
  use Application
  alias Snitch.StartupCode

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    {:ok, pid} =
      Supervisor.start_link(
        [
          supervisor(Snitch.Repo, [])
        ],
        strategy: :one_for_one,
        name: Snitch.Supervisor
      )

    StartupCode.run()
    {:ok, pid}
  end
end
