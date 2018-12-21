defmodule AdminAppWeb.DataExportMail do
  @moduledoc """
  Composing email to send order/product data export.
  """

  import Swoosh.Email
  alias AdminAppWeb.Mailer

  def data_export_mail(attachment, user, format, type) do
    sender_email = Application.get_env(:admin_app, AdminAppWeb.Endpoint)[:sendgrid_sender_mail]

    new()
    |> to(user.email)
    |> from({"Aviacommerce", sender_email})
    |> subject("Your #{type}s")
    |> text_body("Here is the #{format} export of your #{type}s.")
    |> attachment(attachment)
    |> Mailer.deliver()
  end
end
