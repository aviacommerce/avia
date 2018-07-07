defmodule SnitchApiWeb.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :snitch_api,
    module: SnitchApi.Guardian,
    error_handler: SnitchApi.AuthErrorHandler

  plug(Guardian.Plug.VerifyHeader, realm: "Bearer")
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource)

  # If there is a session token, restrict it to an access token and validate it
  plug(Guardian.Plug.VerifySession, claims: %{"typ" => "access"})
  # If there is an authorization header, restrict it to an access token and validate it
  plug(Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"})
  # Load the user if either of the verifications worked
  plug(Guardian.Plug.LoadResource, allow_blank: true)
end
