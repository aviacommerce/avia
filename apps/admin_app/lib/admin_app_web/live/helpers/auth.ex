defmodule AdminAppWeb.Live.Helpers.Auth do
  import Phoenix.LiveView, only: [assign: 3]

  def prepare_assigns(%{"guardian_default_token" => guardian_default_token}, _socket)
      when is_nil(guardian_default_token),
      do: nil

  def prepare_assigns(%{"guardian_default_token" => guardian_default_token}, socket) do
    with {:ok, claims} <- AdminAppWeb.Guardian.decode_and_verify(guardian_default_token),
         {:ok, user} <- AdminAppWeb.Guardian.resource_from_claims(claims) do
      {:ok, assign(socket, :current_user, user)}
    else
      _ -> {:error, socket}
    end
  end
end
