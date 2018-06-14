defmodule Snitch.Data.Schema.StateZoneMember do
  @moduledoc """
  Models a StateZone member.
  """
  use Snitch.Data.Schema

  alias Snitch.Data.Schema.{State, Zone}

  @typedoc """
  StateZoneMember struct.

  ## Fields

  * `zone_id` uniquely determines both `Zone` and `StateZone`
  """
  @type t :: %__MODULE__{}

  schema "snitch_state_zone_members" do
    belongs_to(:zone, Zone)
    belongs_to(:state, State)
    timestamps()
  end

  @update_fields ~w(state_id)a
  @create_fields [:zone_id | @update_fields]

  @doc """
  Returns a `StateZoneMember` changeset to create a new `state_zone_member`.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(state_zone_member, params) do
    state_zone_member
    |> cast(params, @create_fields)
    |> validate_required(@create_fields)
    |> foreign_key_constraint(:zone_id)
    |> unique_constraint(:state_id, name: :snitch_state_zone_members_zone_id_state_id_index)
    |> foreign_key_constraint(:state_id)
    |> check_constraint(
      :zone_id,
      name: :state_zone_exclusivity,
      message: "does not refer a state zone"
    )
  end

  @doc """
  Returns a `StateZoneMember` changeset to update the `state_zone_member`.
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(state_zone_member, params) do
    state_zone_member
    |> cast(params, @update_fields)
    |> foreign_key_constraint(:state_id)
    |> unique_constraint(:state_id, name: :snitch_state_zone_members_zone_id_state_id_index)
  end
end
