defmodule MailManager do
  use GenServer
  alias Snitch.Tools.OrderEmail

  def handle_cast({:send_mail, order}, state) do
    {ok, _} =
      Task.Supervisor.start_child(MailManager.TaskSupervisor, fn ->
        OrderEmail.order_confirmation_mail(order)
      end)

    {:noreply, state}
  end

  ### Client API / Helper functions
  def start_link(name: name), do: GenServer.start_link(__MODULE__, :ok, name: name)

  def send_mail(order) do
    GenServer.cast(__MODULE__, {:send_mail, order})
  end
end
