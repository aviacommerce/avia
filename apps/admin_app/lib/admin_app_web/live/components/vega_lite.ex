defmodule AdminAppWeb.VegaLiteComponent do
  use AdminAppWeb, :live_component

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, id: assigns.id)
    # Send the specification object to the hook, where it gets
    # rendered using the client side Vega-Lite package
    {:ok, push_event(socket, "vega_lite:#{socket.assigns.id}:init", %{"spec" => assigns.spec})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id={"vega-lite-#{@id}"} phx-hook="VegaLite" phx-update="ignore" data-id={@id} >
    </div>
    """
  end
end
