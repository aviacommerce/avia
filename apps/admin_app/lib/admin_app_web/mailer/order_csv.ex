defmodule AdminAppWeb.OrderCsvMail do
    @moduledoc """
    Composing email to send order csv export.
    """

    import Swoosh.Email
    alias AdminAppWeb.Mailer
  
    def order_csv_mail(csv_attachment) do
      sender_email = Application.get_env(:admin_app, AdminAppWeb.Endpoint)[:sendgrid_sender_mail]

      new()
      |> to("jyotigautam108@gmail.com")
      |> from({"Aviacommerce", sender_email})
      |> subject("Your orders")
      |> text_body("Here is the csv export of your orders.")
      |> attachment(csv_attachment)
      |> Mailer.deliver()
    end
  end