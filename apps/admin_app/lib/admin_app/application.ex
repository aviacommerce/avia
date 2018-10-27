defmodule AdminApp.Application do
  @moduledoc false

  use Application
  alias AdminAppWeb.Endpoint

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(AdminAppWeb.Endpoint, [])
      # Start your own worker by calling: AdminApp.Worker.start_link(arg1, arg2, arg3)
      # worker(AdminApp.Worker, [arg1, arg2, arg3]),
    ]

    :ok = Honeydew.start_queue(:etsy_import_queue)
    :ok = Honeydew.start_workers(:etsy_import_queue, Avia.Etsy.ImportWorker)
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AdminApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
