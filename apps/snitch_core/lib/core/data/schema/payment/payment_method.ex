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
  Returns a `PaymentMethod` changeset.
  """
  @spec changeset(__MODULE__.t(), map, :create | :update) :: Ecto.Changeset.t()
  def changeset(payment_method, params, :create) do
    payment_method
    |> cast(params, @create_fields)
    |> validate_required(@create_fields)
    |> validate_length(:code, is: 3)
    |> unique_constraint(:code)
  end

  def changeset(payment_method, params, :update) do
    payment_method
    |> cast(params, @update_fields)
  end
end
