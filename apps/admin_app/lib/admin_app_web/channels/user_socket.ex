defmodule AdminAppWeb.UserSocket do
  use Phoenix.Socket
  @secret_key_base Application.get_env(:admin_app, AdminAppWeb.Endpoint)[:secret_key_base]

  ## Channels
  # channel "room:*", AdminAppWeb.RoomChannel
  channel("product:*", AdminAppWeb.ProductChannel)
  channel("order:*", AdminAppWeb.OrderChannel)

  ## Transports
  transport(:websocket, Phoenix.Transports.WebSocket)
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  # def connect(_params, socket) do
  #   {:ok, socket}
  # end

  def connect(%{"token" => token}, socket) do
    # max_age: 1209600 is equivalent to two weeks in seconds
    case Phoenix.Token.verify(
           socket,
           @secret_key_base,
           token,
           max_age: 86_400
         ) do
      {:ok, tenant_user_id} ->
        [tenant, user_id] = String.split(tenant_user_id, "_")

        socket =
          socket
          |> assign(:user_token, token)
          |> assign(:tenant, tenant)
          |> assign(:current_user, user_id)

        {:ok, socket}

      {:error, reason} ->
        :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     AdminAppWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
