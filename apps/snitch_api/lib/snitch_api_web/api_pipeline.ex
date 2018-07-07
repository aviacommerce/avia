defmodule SnitchApiWeb.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :snitch_api,
    module: SnitchApi.Guardian,
    error_handler: SnitchApi.AuthErrorHandler

  plug(Guardian.Plug.VerifyHeader, realm: "Bearer")
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource)
end
