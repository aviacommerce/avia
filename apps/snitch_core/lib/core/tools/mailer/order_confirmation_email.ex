defmodule Snitch.Tools.OrderEmail do
  @moduledoc """
  Composing email to send order confirmation mail.
  """
  use Bamboo.EEx
  alias Snitch.Tools.Mailer
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Schema.GeneralConfiguration, as: GC
  alias Snitch.Tools.Helper.ImageUploader
  require EEx

  email_template =
    Path.join([
      File.cwd!(),
      "lib/core/tools/mailer/email_templates/order_confirmation_email.html.eex"
    ])

  EEx.function_from_file(:defp, :order_email, email_template, [:assigns])

  def order_confirmation_mail(order) do
    general_config = Repo.all(GC) |> List.first() |> Repo.preload(:image)
    send_mail(general_config, order)
  end

  defp send_mail(nil, order), do: nil

  defp send_mail(general_config, order) do
    sender_email = general_config.sender_mail
    order = Repo.preload(order, [:user, line_items: [product: :images]])
    user_email = order.user.email

    logo = if general_config.image != nil, do: general_config.image.name, else: nil

    mail_template =
      order_email(%{
        order: order,
        frontend_base_url: general_config.frontend_url,
        backend_base_url: general_config.backend_url,
        general_config: general_config,
        logo: logo
      })

    store_name = general_config.name

    email =
      new_email()
      |> to(user_email)
      |> from({"#{store_name}", sender_email})
      |> subject(
        "Order Confirmation - Your Order with #{store_name} has been successfully placed!"
      )
      |> html_body(mail_template)

    try do
      email |> Mailer.deliver_now()
    rescue
      e in ArgumentError -> nil
    end
  end
end
