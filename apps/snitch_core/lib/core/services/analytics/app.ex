defmodule Snitch.Service.Analytics.Supervisor do
  @moduledoc """
  Supervisor for Honeydew Worker queue.

  Uses ErlangQueue.
  """

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      Honeydew.queue_spec(:analytics_queue),
      Honeydew.worker_spec(:analytics_queue, Snitch.Service.Analytics.Jobs)
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
