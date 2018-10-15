defmodule Snitch.Domain.Payment do
  @moduledoc """
  Helper functions and utlities for handling payments.
  """

  use Snitch.Domain

  alias Snitch.Data.Model.HostedPayment
  alias SnitchPayments.PaymentMethodCode
  alias Snitch.Data.Schema.{Order, PaymentMethod, Payment}

  @hosted_payment PaymentMethodCode.hosted_payment()
  @cod_payment PaymentMethodCode.cash_on_delivery()

  @doc """
   Creates payment record in the `pending` state.

   The function handles creation of both the payment record as
   well as the subtype in the same transaction.

   The differentiation for the `payment` subtypes is being made from
   the `:code` field in the `payment_method` struct.
   ## See
   `Snitch.Data.Schema.PaymentMethod`

   The `params` map expects the attributes for `subtype` and `payment`
   under `:subtype_params` and `payment_params` keys.

   ## Example
   For the subtype `hosted payment` the `params` map would be.

       iex> params = %{
             subtype_params: %{},
             payment_params: %{
               amount: Money.new(10, :USD)
             }
           }
  """
  @spec create_payment(map, PaymentMethod.t(), Order.t()) ::
          {:ok, map} | {:error, Ecto.Changeset.t()}
  def create_payment(params, payment_method, order) do
    slug = get_slug()
    payment_params = params[:payment_params]
    subtype_params = params[:subtype_params]

    create_payment_with_subtype(
      payment_method.code,
      subtype_params,
      payment_params,
      slug,
      order.id,
      payment_method.id
    )
  end

  defp create_payment_with_subtype(
         @hosted_payment,
         hosted_params,
         payment_params,
         slug,
         order_id,
         payment_method_id
       ) do
    HostedPayment.create(
      slug,
      order_id,
      payment_params,
      hosted_params,
      payment_method_id
    )
  end

  defp create_payment_with_subtype(
         @cod_payment,
         _,
         payment_params,
         slug,
         order_id,
         payment_method_id
       ) do
    payment = struct(Payment, payment_params)

    more_payment_params = %{
      order_id: order_id,
      payment_type: PaymentMethodCode.cash_on_delivery(),
      payment_method_id: payment_method_id,
      slug: slug
    }

    changeset = Payment.create_changeset(payment, more_payment_params)
    Repo.insert(changeset)
  end

  # generates a unique slug using nano id
  # TODO look for a better alternative.
  defp get_slug() do
    "payment_slug-#{Nanoid.generate()}"
  end
end
