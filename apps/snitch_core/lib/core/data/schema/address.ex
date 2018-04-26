defmodule Snitch.Data.Schema.Address do
  @moduledoc """
  Models an Address

  An `Address` must contain a reference to `Snitch.Data.Schema.Country` and only if the
  country has states a reference to a `Snitch.Data.Schema.State`. This means some
  Addresses might not have a State.
  """

  use Snitch.Data.Schema

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

    # TODO: associate address with state and country
    # has_one :state, State
    # has_one :country, Country
    timestamps()
  end

  # state_id country_id)a
  @required_fields ~w(first_name last_name address_line_1 city zip_code)a
  @optional_fields ~w(phone alternate_phone)a

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = address, params) do
    address
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:address_line_1, min: 10)

    # |> foreign_key_constraint(:state_id, Snitch.Data.Schema.State)
    # |> foreign_key_constraint(:country_id, Snitch.Data.Schema.Country)
  end
end
