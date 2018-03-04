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

  @update_fields ~w(slug state order_id)a
  @create_fields @update_fields ++ ~w(amount payment_type payment_method_id)a

  @doc """
  Returns a `Payment` changeset.

  `:payment_type` is required when `action` is `:create`. When `action` is
  `:update`, the `:payment_type` and `amount` if provided, are simply ignored.

  Consider deleting the payment if you wish to "change" the payment type.
  """
  @spec changeset(__MODULE__.t(), map, :create | :update) :: Ecto.Changeset.t()
  def changeset(payment, params, action)

  def changeset(payment, params, :create) do
    payment
    |> cast(params, @create_fields)
    |> validate_required(@create_fields)
    |> validate_discriminator(:payment_type, @payment_types)
    |> foreign_key_constraint(:payment_method_id)
    |> do_changeset()
  end

  def changeset(payment, params, :update) do
    payment
    |> cast(params, @update_fields)
    |> do_changeset()
  end

  defp do_changeset(changeset) do
    changeset
    |> foreign_key_constraint(:order_id)
    |> validate_amount(:amount)
    |> unique_constraint(:slug)
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
