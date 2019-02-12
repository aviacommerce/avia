defmodule Snitch.Application do
  @moduledoc """
  The Snitch Application Service.

  The Snitch system business domain lives in this application.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    {:ok, pid} =
      Supervisor.start_link(
        [
          supervisor(Snitch.Repo, []),
          supervisor(Snitch.Tools.ElasticsearchCluster, []),
          worker(Cachex, [:avia_cache, [limit: 1000]]),
          supervisor(Task.Supervisor, [[name: MailManager.TaskSupervisor]]),
          worker(MailManager, [[name: MailManager]])
        ],
        strategy: :one_for_one,
        name: Snitch.Supervisor
      )

    {:ok, pid}
  end
end
