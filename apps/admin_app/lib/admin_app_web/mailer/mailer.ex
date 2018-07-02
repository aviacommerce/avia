defmodule AdminAppWeb.Mailer do
  @moduledoc """
  Mail delivery module for Snitch.
  """
  use Swoosh.Mailer, otp_app: :admin_app
end
