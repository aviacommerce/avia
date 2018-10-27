defmodule Snitch.Service.StoreImporter do
  @moduledoc false
  
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      Honeydew.queue_spec(:import_queue, []),
      Honeydew.worker_spec(:import_queue, Avia.Etsy.ImportWorker, [])
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
