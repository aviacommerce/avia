defmodule Snitch.Tools.OrderEmailTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  use Bamboo.Test

  import Snitch.Factory
  alias Snitch.Tools.OrderEmail

  setup :order_with_user
  setup :order_with_lineitem

  test "send order confirmation mail succesfully", %{order_with_lineitem: line_item} do
    config = insert(:general_config)
    assert_delivered_email(OrderEmail.order_confirmation_mail(line_item.order))
  end

  test "send order confirmation mail without general_config set", %{
    order_with_lineitem: line_item
  } do
    email = OrderEmail.order_confirmation_mail(line_item.order)
    assert email == nil
  end

  test "successful order confirmation mail's body", %{order_with_lineitem: line_item} do
    config = insert(:general_config)
    email = OrderEmail.order_confirmation_mail(line_item.order)

    assert email.subject ==
             "Order Confirmation - Your Order with #{config.name} has been successfully placed!"

    assert email.to == [nil: line_item.order.user.email]
    assert email.from == {"#{config.name}", "hello@aviabird.com"}
  end
end
