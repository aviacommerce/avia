defmodule AdminAppWeb.OrderExportMail do
  @moduledoc """
  Composing email to send order export.
  """

  import Swoosh.Email
  alias AdminAppWeb.Mailer

  def order_export_mail(attachment, user, type) do
    sender_email = Application.get_env(:admin_app, AdminAppWeb.Endpoint)[:sendgrid_sender_mail]

    new()
    |> to(user.email)
    |> from({"Aviacommerce", sender_email})
    |> subject("Your orders")
    |> text_body("Here is the #{type} export of your orders.")
    |> attachment(attachment)
    |> Mailer.deliver()
  end
end
