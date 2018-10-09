defmodule AdminAppWeb.AuthenticationPipe do
  @moduledoc false

  use Guardian.Plug.Pipeline, otp_app: :admin_app

  plug(Guardian.Plug.VerifySession)
  plug(Guardian.Plug.LoadResource, allow_blank: false)
  plug(Guardian.Plug.EnsureAuthenticated)
end
