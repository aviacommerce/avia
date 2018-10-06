defmodule Snitch.Data.Schema.Address do
  @moduledoc """
  Models an Address

  An `Address` must contain a reference to `Snitch.Data.Schema.Country` and only if the
  country has states a reference to a `Snitch.Data.Schema.State`. This means some
  Addresses might not have a State.
  """

  use Snitch.Data.Schema

  alias Snitch.Data.Schema.{Country, State}

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

    belongs_to(:state, State, on_replace: :nilify)
    belongs_to(:country, Country, on_replace: :nilify)
    belongs_to(:user, User)
    timestamps()
  end

  @required_fields ~w(first_name last_name address_line_1 city zip_code country_id user_id)a
  @cast_fields ~w(phone alternate_phone state_id address_line_2)a ++ @required_fields

  @doc """
  Returns an `Address` changeset to create OR update `address`.

  An address must be associated with a country, and if the country has
  sub-divisions (aka states) according to ISO 3166-2, then the address must also
  be associated with a state.

  ## Note
  You may only provide `:country_id` and `:state_id`, structs under `:country`
  and `:state` are ignored.
  """
  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = address, params) do
    address
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
    |> validate_length(:address_line_1, min: 10)
    |> assoc_country_and_state()
  end

  defp assoc_country_and_state(
         %{
           valid?: true,
           changes: %{
             country_id: c_id,
             state_id: s_id
           }
         } = changeset
       ) do
    case Repo.get(Country, c_id) do
      nil ->
        add_error(changeset, :country_id, "does not exist", country_id: c_id)

      %Country{} = country ->
        changeset
        |> put_assoc(:country, country)
        |> assoc_state(country, s_id)
    end
  end

  defp assoc_country_and_state(
         %{
           valid?: true,
           changes: %{state_id: s_id},
           data: %{country_id: c_id}
         } = changeset
       ) do
    case Repo.get(Country, c_id) do
      nil ->
        add_error(changeset, :country_id, "does not exist", country_id: c_id)

      %Country{} = country ->
        assoc_state(changeset, country, s_id)
    end
  end

  defp assoc_country_and_state(
         %{
           valid?: true,
           changes: %{country_id: c_id}
         } = changeset
       ) do
    case Repo.get(Country, c_id) do
      nil ->
        add_error(changeset, :country_id, "does not exist", country_id: c_id)

      %Country{} = country ->
        changeset
        |> put_assoc(:country, country)
        |> assoc_state(country, nil)
    end
  end

  defp assoc_country_and_state(changeset), do: changeset

  defp assoc_state(changeset, %Country{states_required: false}, _) do
    put_change(changeset, :state_id, nil)
  end

  defp assoc_state(changeset, %{states_required: true} = country, s_id) when is_integer(s_id) do
    case Repo.get(State, s_id) do
      nil ->
        add_error(changeset, :state_id, "does not exist", state_id: s_id)

      %State{} = state ->
        if state.country_id == country.id do
          put_assoc(changeset, :state, state)
        else
          add_error(
            changeset,
            :state,
            "state does not belong to country",
            state_id: state.id,
            country_id: country.id
          )
        end
    end
  end

  defp assoc_state(changeset, %{states_required: true} = country, _) do
    add_error(
      changeset,
      :state_id,
      "state is explicitly required for this country",
      country_id: country.id
    )
  end
end
