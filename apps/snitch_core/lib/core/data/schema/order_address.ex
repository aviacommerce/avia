defmodule Snitch.Data.Schema.OrderAddress do
  @moduledoc false

  use Snitch.Data.Schema

  alias Snitch.Data.Schema.{Country, State}

  @required_fields ~w(first_name last_name address_line_1 city zip_code country_id)a
  @cast_fields ~w(phone alternate_phone state_id)a ++ @required_fields

  embedded_schema do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:address_line_1, :string)
    field(:address_line_2, :string)
    field(:city, :string)
    field(:zip_code, :string)
    field(:phone, :string)
    field(:alternate_phone, :string)

    field(:state_id, :integer)
    field(:country_id, :integer)
  end

  def changeset(%__MODULE__{} = address, params) do
    address
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
    |> validate_length(:address_line_1, min: 10)
    |> assoc_state_and_country()
  end

  defp assoc_state_and_country(
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
        assoc_state(changeset, country, s_id)
    end
  end

  defp assoc_state_and_country(
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

  defp assoc_state_and_country(
         %{
           valid?: true,
           changes: %{country_id: c_id}
         } = changeset
       ) do
    case Repo.get(Country, c_id) do
      nil ->
        add_error(changeset, :country_id, "does not exist", country_id: c_id)

      %Country{} = country ->
        assoc_state(changeset, country, nil)
    end
  end

  defp assoc_state_and_country(changeset), do: changeset

  defp assoc_state(changeset, %Country{states_required: false}, _) do
    put_change(changeset, :state_id, nil)
  end

  defp assoc_state(changeset, %{states_required: true} = country, s_id) when is_integer(s_id) do
    case Repo.get(State, s_id) do
      nil ->
        add_error(changeset, :state_id, "does not exist", state_id: s_id)

      %State{} = state ->
        if state.country_id == country.id do
          changeset
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
