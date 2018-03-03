defmodule Core.Snitch.Address do
  @moduledoc """
  Models an Address

  An `Address` must contain a reference to `Core.Snitch.Country` and only if the
  country has states a reference to a `Core.Snitch.State`. This means some
  Addresses might not have a State.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "snitch_addresses" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:address_line_1, :string)
    field(:address_line_2, :string)
    field(:city, :string)
    field(:zip_code, :string)
    field(:phone, :string)
    field(:alternate_phone, :string)

    # has_one :state, State
    # has_one :country, Country
    timestamps()
  end

  # state_id country_id)a
  @required_fields ~w(first_name last_name address_line_1 city zip_code)a
  @optional_fields ~w(phone alternate_phone)a

  @spec changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def changeset(address, params \\ %{}) do
    address
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:address_line_1, min: 10)

    # |> foreign_key_constraint(:state_id, Core.Snitch.State)
    # |> foreign_key_constraint(:country_id, Core.Snitch.Country)
  end
end
