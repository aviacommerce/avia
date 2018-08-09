defmodule Snitch.Data.Schema.PaymentMethod do
  @moduledoc """
  Models a PaymentMethod.
  """

  use Snitch.Data.Schema

  alias Snitch.Data.Schema.Payment

  @typedoc """
  A struct which represents PaymentMethod.

  All the fields mentioned in the struct map
  to fields of the database table.

  The fields are:
    * `name`:         - Stores the name which would be shown to the user.
    * `code`:         - Stores a code to identify the type of the payment.
                        See `SnitchPayments.PaymentMethodCode`.
    * `active?`:      - A boolean to determine whether payment method is active
                        or not in latter case is not shown to the user.
    * `live_mode?`:   - A boolean to determine whether `test`_url or `live`_url
                        shoulde be used for the `provider`.
    * `provider`:     - Stores the name of the module which implements the logic
                        for handling the transactions. The providers are picked
                        from gateways in `SnitchPayments`.
    * `preferences`:  - A map to store credentials for the provider gateway.
                        TODO: Move preferences to a separate db or store it
                        after encoding.
  """
  @type t :: %__MODULE__{}

  schema "snitch_payment_methods" do
    field(:name, :string)
    field(:code, :string, size: 3)
    field(:active?, :boolean, default: true)

    field(:live_mode?, :boolean, default: false)
    field(:provider, Ecto.Atom)
    field(:preferences, :map)
    field(:description, :string)

    has_many(:payments, Payment)

    timestamps()
  end

  @required_fields ~w(name provider code)a
  @update_fields ~w(name active? provider live_mode? preferences description)a
  @create_fields [:code | @update_fields]

  @doc """
  Returns a `PaymentMethod` changeset for a new `payment_method`.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = payment_method, params) do
    payment_method
    |> cast(params, @create_fields)
    |> validate_required(@required_fields)
    |> validate_length(:code, is: 3)
    |> unique_constraint(:name)
    |> modify_provider_name()
  end

  defp modify_provider_name(%Ecto.Changeset{valid?: true} = changeset) do
    case fetch_change(changeset, :provider) do
      {:ok, provider} ->
        put_change(changeset, :provider, Module.safe_concat(Elixir, provider))

      :errror ->
        changeset
    end
  end

  defp modify_provider_name(changeset), do: changeset

  @doc """
  Returns a `PaymentMethod` changeset to update `payment_method`.
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = payment_method, params) do
    cast(payment_method, params, @update_fields)
  end
end
