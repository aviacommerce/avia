defmodule Snitch.Data.Schema.State do
  @moduledoc """
  Models a State
  """
  use Snitch.Data.Schema
  alias Snitch.Data.Schema.Country

  @type t :: %__MODULE__{}

  schema "snitch_states" do
    field(:name, :string)
    field(:code, :string)
    belongs_to(:country, Country)

    timestamps()
  end

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = state, params) do
    state
    |> cast(params, [:code, :name, :country_id])
    |> validate_required([:code, :name, :country_id])
    |> foreign_key_constraint(:country_id)
    |> unique_constraint(:code)
  end

  @doc """
  Returns a JSON encodable `map`.

  Associations that are not loaded are rendered as `nil`.
  """
  @spec to_map(__MODULE__.t()) :: map
  def to_map(%__MODULE__{} = state) do
    state
    |> Map.from_struct()
    |> Map.delete(:__meta__)
    |> Map.update!(:country, &Country.to_map/1)
  end

  @spec to_map([__MODULE__.t()]) :: [map]
  def to_map(states) when is_list(states) do
    Enum.map(states, &to_map/1)
  end

  def to_map(_), do: nil
end

defimpl Jason.Encoder, for: Snitch.Data.Schema.State do
  def encode(state, opts) do
    Jason.Encode.map(@for.to_map(state), opts)
  end
end
