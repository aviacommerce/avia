defmodule Snitch.Tools.OrderEmail do
  @moduledoc """
  Composing email to send order confirmation mail.
  """
  use Bamboo.EEx, path: Path.join([File.cwd!(), "lib/core/tools/mailer/email_templates"])
  alias Snitch.Tools.Mailer
  alias Snitch.Repo

  def order_confirmation_mail(order) do
    sender_email = Application.get_env(:snitch_core, Snitch.Tools.Mailer)[:sendgrid_sender_mail]
    order = Repo.preload(order, [:user, line_items: :product])
    user_email = order.user.email

    new_email()
    |> to(user_email)
    |> from({"Snitch", sender_email})
    |> subject("Order Confirmation - Your Order with Snitch has been successfully placed!
            ")
    |> render_to_html("order_confirmation_email.html.eex", %{order: order})
    |> Mailer.deliver_now()
  end
end
