defmodule Snitch.Data.Schema.Address do
  @moduledoc """
  Models an Address

  An `Address` must contain a reference to `Snitch.Data.Schema.Country` and only if the
  country has states a reference to a `Snitch.Data.Schema.State`. This means some
  Addresses might not have a State.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{State, Country}

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

    belongs_to(:state, State)
    belongs_to(:country, Country)
    timestamps()
  end

  @required_fields ~w(first_name last_name address_line_1 city zip_code)a
  @optional_fields ~w(phone alternate_phone)a

  @doc """
  Returns an `Address` changeset to create a new `address`.

  An address must be associated with a country, and if the country has
  sub-divisions (aka states) according to ISO 3166-2, then the address must also
  be associated with a state.

  ## Note
  * `country` must be a `Country.t` struct.
  * `state` must be a `State.t` struct.
  """
  @spec create_changeset(t, map, Country.t(), State.t()) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = address, params, %Country{} = country, state \\ nil) do
    address
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:address_line_1, min: 10)
    |> put_assoc(:country, country)
    |> validate_country_and_state(country, state)
  end

  @spec validate_country_and_state(Ecto.Changeset.t(), Country.t(), State.t() | nil) ::
          Ecto.Changeset.t()
  def validate_country_and_state(
        %Ecto.Changeset{valid?: true} = changeset,
        %{states_required: true} = country,
        state
      )
      when is_map(state) do
    if state.country_id == country.id do
      put_assoc(changeset, :state, state)
    else
      add_error(
        changeset,
        :state,
        "state does not belong to country",
        state_id: state.id,
        country_id: country.id,
        validation: :address
      )
    end
  end

  def validate_country_and_state(
        %Ecto.Changeset{valid?: true} = changeset,
        %{states_required: true} = country,
        nil
      ) do
    add_error(changeset, :state, "state is required for this country", country_id: country.id)
  end

  def validate_country_and_state(changeset, _, _), do: changeset
end
