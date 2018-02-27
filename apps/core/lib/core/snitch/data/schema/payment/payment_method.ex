defmodule Core.Snitch.Data.Schema.PaymentMethod do
  @moduledoc """
  Models a PaymentMethod
  """

  use Core.Snitch.Data.Schema

  @type t :: %__MODULE__{}

  schema "snitch_payment_methods" do
    field(:name, :string)
    field(:code, :string, size: 3)
    field(:active?, :boolean, default: true)

    has_many(:payments, Payment)

    timestamps()
  end

  @required_fields ~w(name code active?)a

  @doc """
  Returns a `PaymentMethod` changeset.
  """
  @spec changeset(__MODULE__.t(), map, :create | :update) :: Ecto.Changeset.t()
  def changeset(payment_method, params, _) do
    payment_method
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:code)
  end
end
