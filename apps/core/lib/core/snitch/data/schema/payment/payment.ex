defmodule Core.Snitch.Data.Schema.Payment do
  @moduledoc """
  Models a Payment
  """

  use Core.Snitch.Data.Schema

  @type t :: %__MODULE__{}

  @payment_types ["chk", "ccd"]

  schema "snitch_payments" do
    field(:slug, :string)
    field(:payment_type, :string, size: 3)
    field(:amount, Money.Ecto.Composite.Type, default: Money.new(0, :USD))
    field(:state, :string, default: "pending")

    belongs_to(:payment_method, PaymentMethod)
    belongs_to(:order, Order)
    timestamps()
  end

  @required_fields ~w(slug amount state payment_type payment_method_id order_id)a

  @doc """
  Returns a `Payment` changeset.
  """
  @spec changeset(__MODULE__.t(), map(), :create | :update) :: Ecto.Changeset.t()
  def changeset(payment, params, _) do
    payment
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_discriminator(:payment_type, @payment_types)
    |> validate_amount(:amount)
    |> foreign_key_constraint(:payment_method_id)
    |> foreign_key_constraint(:order_id)
  end

  defp validate_discriminator(%{valid?: true} = changeset, key, permitted) do
    {_, discriminator} = fetch_field(changeset, key)

    if discriminator in permitted do
      changeset
    else
      changeset
      |> add_error(:payment_type, "'#{discriminator}' is invalid", validation: :inclusion)
    end
  end

  defp validate_discriminator(changeset, _, _), do: changeset

  defp validate_amount(%{valid?: true} = changeset, key) do
    {_, amount} = fetch_field(changeset, key)

    if Decimal.cmp(amount.amount, Decimal.new(0)) != :lt do
      changeset
    else
      changeset
      |> add_error(:amount, "must be greater than 0", validation: :amount)
    end
  end

  defp validate_amount(changeset, _), do: changeset
end
