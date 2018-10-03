defmodule Snitch.Tools.OrderEmail do
  @moduledoc """
  Composing email to send order confirmation mail.
  """
  use Bamboo.EEx
  alias Snitch.Tools.Mailer
  alias Snitch.Repo
  require EEx

  email_template =
    Path.join([
      File.cwd!(),
      "lib/core/tools/mailer/email_templates/order_confirmation_email.html.eex"
    ])

  EEx.function_from_file(:defp, :order_email, email_template, [:assigns])

  def order_confirmation_mail(order) do
    sender_email = Application.get_env(:snitch_core, Snitch.Tools.Mailer)[:sendgrid_sender_mail]
    order = Repo.preload(order, [:user, line_items: :product])

    user_email = order.user.email
    mail_template = order_email(%{order: order})

    new_email()
    |> to(user_email)
    |> from({"Snitch", sender_email})
    |> subject("Order Confirmation - Your Order with Snitch has been successfully placed!
            ")
    |> html_body(mail_template)
    |> Mailer.deliver_now()
  end
end
