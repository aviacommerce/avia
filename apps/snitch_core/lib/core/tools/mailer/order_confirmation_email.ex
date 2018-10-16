defmodule Snitch.Tools.OrderEmail do
  @moduledoc """
  Composing email to send order confirmation mail.
  """
  use Bamboo.EEx
  alias Snitch.Tools.Mailer
  alias Snitch.Core.Tools.MultiTenancy.Repo
  require EEx

  email_template =
    Path.join([
      File.cwd!(),
      "lib/core/tools/mailer/email_templates/order_confirmation_email.html.eex"
    ])

  EEx.function_from_file(:defp, :order_email, email_template, [:assigns])

  def order_confirmation_mail(order) do
    frontend_base_url = Application.get_env(:snitch_core, Snitch.BaseUrl)[:frontend_url]
    backend_base_url = Application.get_env(:snitch_core, Snitch.BaseUrl)[:backend_url]
    sender_email = Application.get_env(:snitch_core, Snitch.Tools.Mailer)[:sendgrid_sender_mail]
    order = Repo.preload(order, [:user, line_items: [product: :images]])
    user_email = order.user.email

    mail_template =
      order_email(%{
        order: order,
        frontend_base_url: frontend_base_url,
        backend_base_url: backend_base_url
      })

    email =
      new_email()
      |> to(user_email)
      |> from({"AviaCommerce", sender_email})
      |> subject("Order Confirmation - Your Order with Aviacommerce has been successfully placed!
              ")
      |> html_body(mail_template)

    try do
      email |> Mailer.deliver_now()
    rescue
      e in ArgumentError -> nil
    end
  end
end
