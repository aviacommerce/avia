defmodule Snitch.Data.Schema.Address do
  @moduledoc """
  Models an Address

  An `Address` must contain a reference to `Snitch.Data.Schema.Country` and only if the
  country has states a reference to a `Snitch.Data.Schema.State`. This means some
  Addresses might not have a State.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{State, Country}
  alias Snitch.Repo

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
  @optional_fields ~w(phone alternate_phone country_id state_id)a

  @doc """
  Returns an `Address` changeset to create a new `address`.

  An address must be associated with a country, and if the country has
  sub-divisions (aka states) according to ISO 3166-2, then the address must also
  be associated with a state.

  ## Note
  You can provide either the Country and State structs under the `:country` and
  `:state` keys resp. or just their IDs under `:country_id` and `:state_id`

  If you provide both, the `:country_id` and/or `:state_id` will be ignored.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = address, params) do
    filtered_params =
      params
      |> Stream.reject(fn {_, x} ->
        is_nil(x)
      end)
      |> Enum.into(%{})

    address
    |> cast(filtered_params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:address_line_1, min: 10)
    |> assoc_country_and_state()
  end

  defp assoc_country_and_state(changeset) do
    with :error <- Map.fetch(changeset.params, "country"),
         {:ok, country_id} <- fetch_change(changeset, :country_id),
         nil <- Repo.get(Country, country_id) do
      add_error(changeset, :country_id, "does not exist", country_id: country_id)
    else
      {:ok, %Country{} = country} ->
        changeset
        |> put_assoc(:country, country)
        |> assoc_state(country)

      :error ->
        add_error(changeset, :country, "country or country_id can't be blank")

      %Country{} = country ->
        changeset
        |> put_assoc(:country, country)
        |> assoc_state(country)
    end
  end

  defp assoc_state(changeset, %{states_required: true} = country) do
    with :error <- Map.fetch(changeset.params, "state"),
         {:ok, state_id} <- fetch_change(changeset, :state_id),
         nil <- Repo.get(State, state_id) do
      add_error(changeset, :state_id, "does not exist", state_id: state_id)
    else
      {:ok, %State{} = state} ->
        validate_state(changeset, country, state)

      :error ->
        add_error(changeset, :state, "state is required for this country", country_id: country.id)

      %State{} = state ->
        validate_state(changeset, country, state)
    end
  end

  defp assoc_state(changeset, _), do: changeset

  defp validate_state(changeset, country, state) do
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
