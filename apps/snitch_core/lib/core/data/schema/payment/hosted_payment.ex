defmodule Snitch.Data.Schema.HostedPayment do
  @moduledoc """
  Models a Payment by a hosted payment service.

  This is a subtype of `Payment`. The record will be deleted if the supertype
  `Payment` is deleted!

  > **On the other hand**, the subtype `HostedPayment` can be freely deleted without
    deleting it's supertype `Payment` record.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.Payment

  @type t :: %__MODULE__{}

  schema "snitch_hosted_payments" do
    field(:transaction_id, :string)
    field(:payment_source, :string)
    field(:raw_response, :map)
    belongs_to(:payment, Payment)

    timestamps()
  end

  @create_fields ~w(transaction_id raw_response payment_source payment_id)a
  @update_fields ~w(transaction_id raw_response payment_source)a

  @doc """
  Returns a `HostedPayment` changeset for new hosted payment.

  `:payment_id` is required
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = hosted_payment, params) do
    hosted_payment
    |> cast(params, @create_fields)
    |> unique_constraint(:payment_id)
    |> foreign_key_constraint(:payment_id)
    |> check_constraint(
      :payment_id,
      name: :hosted_payment_exclusivity,
      message: "does not refer a hosted payment"
    )
  end

  @doc """
  Returns an update changeset for `HostedPayment`.

   Note that `:payment_id` cannot be changed, consider deleting this
  `hosted_payment` instead and creating a new `Snitch.Data.Schema.Payment` as well
  as `Snitch.Data.Schema.HOstedPayment`.
  """

  def update_changeset(%__MODULE__{} = hosted_payment, params) do
    cast(hosted_payment, params, @update_fields)
  end
end
