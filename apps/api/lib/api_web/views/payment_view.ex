defmodule ApiWeb.PaymentView do
  use ApiWeb, :view

  def render("payment.json", %{payment: payment}) do
    payment
    |> Map.from_struct()
    |> Map.drop(~w[__meta__ order payment_method]a)
    |> Map.merge(%{
      amount: payment.amount,
      display_amount: Money.to_string!(payment.amount),
      number: payment.slug
    })
  end

  def render("payment_methods.json", %{payment_methods: payments}) do
    %{
      payment_methods: render_many(payments, __MODULE__, "payment_method.json"),
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

  @translate %{
    "card" => "Credit Card",
    "check" => "Check"
  }

  def render("payment_method.json", %{payment: payment}) do
    name = Map.get(@translate, payment.name, payment.name)

    %{
      id: payment.id,
      name: name,
      description: "Pay by #{name}"
    }
  end
end
