defmodule Snitch.Data.Schema.PaymentMethod do
  @moduledoc """
  Models a PaymentMethod
  """

  use Snitch.Data.Schema

  alias Snitch.Data.Schema.Payment

  @type t :: %__MODULE__{}

  schema "snitch_payment_methods" do
    field(:name, :string)
    field(:code, :string, size: 3)
    field(:active?, :boolean, default: true)

    has_many(:payments, Payment)

    timestamps()
  end

  @update_fields ~w(name active?)a
  @create_fields [:code | @update_fields]

  @doc """
  Returns a `PaymentMethod` changeset for a new `payment_method`.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = payment_method, params) do
    payment_method
    |> cast(params, @create_fields)
    |> validate_required(@create_fields)
    |> validate_length(:code, is: 3)
    |> unique_constraint(:code)
  end

  @doc """
  Returns a `PaymentMethod` changeset to update `payment_method`.
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = payment_method, params) do
    cast(payment_method, params, @update_fields)
  end
end
