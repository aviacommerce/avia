defmodule ApiWeb.PaymentView do
  use ApiWeb, :view

  def render("payment_methods.json", %{payment_methods: payments}) do
    %{
      payent_methods: render_many(payments, __MODULE__, "payment_method.json"),
      attributes: [
        "id",
        "source_type",
        "source_id",
        "amount",
        "display_amount",
        "payment_method_id",
        "state",
        "avs_response",
        "created_at",
        "updated_at",
        "number"
      ]
    }
  end

  def render("payment_method.json", %{payment: payment}) do
    %{
      id: payment.id,
      name: payment.name,
      description: "Pay by #{payment.name}"
    }
  end
end
