defmodule Snitch.Tools.OrderEmailTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  use Bamboo.Test

  import Snitch.Factory
  alias Snitch.Tools.OrderEmail
  alias Snitch.Data.Model.GeneralConfiguration, as: GCModel
  alias Snitch.Data.Model.Image

  @img "test/support/image.png"

  setup :order_with_user
  setup :order_with_lineitem

  setup do
    config_params = %{
      "name" => "store",
      "sender_mail" => "hello@aviabird.com",
      "frontend_url" => "https://abc.com",
      "backend_url" => "https://abc.com",
      "seo_title" => "store",
      "currency" => "USD",
      "image" => %{
        type: "image/png",
        filename: "3Lu6PTMFSHz8eQfoGCP3F.png",
        path: @img
      }
    }

    [
      config_params: config_params
    ]
  end

  test "send order confirmation mail succesfully", %{
    order_with_lineitem: line_item,
    config_params: config_params
  } do
    {:ok, config} = GCModel.create(config_params)
    assert_delivered_email(OrderEmail.order_confirmation_mail(line_item.order))
    Image.delete_image(config_params["image"].filename, config)
  end

  test "send order confirmation mail without general_config set", %{
    order_with_lineitem: line_item
  } do
    email = OrderEmail.order_confirmation_mail(line_item.order)
    assert email == nil
  end

  test "successful order confirmation mail's body", %{
    order_with_lineitem: line_item,
    config_params: config_params
  } do
    {:ok, config} = GCModel.create(config_params)

    email = OrderEmail.order_confirmation_mail(line_item.order)

    assert email.subject ==
             "Order Confirmation - Your Order with #{config.name} has been successfully placed!"

    assert email.to == [nil: line_item.order.user.email]
    assert email.from == {"#{config.name}", "hello@aviabird.com"}
    Image.delete_image(config_params["image"].filename, config)
  end
end
