defmodule MailManager do
  use GenServer
  alias Snitch.Tools.OrderEmail
  require Logger

  # Internal Callbacks

  def init(:ok) do
    Logger.debug("Init (:ok)")
    {:ok, nil}
  end

  def handle_cast({:send_mail, order}, state) do
    {:ok, _pid} =
      Task.Supervisor.start_child(MailManager.TaskSupervisor, fn ->
        OrderEmail.order_confirmation_mail(order)
      end)

    {:noreply, state}
  end

  ### Client API / Helper functions
  def start_link do
    Logger.debug("Starting GenServer")
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def send_mail(order) do
    GenServer.cast(__MODULE__, {:send_mail, order})
  end
end
