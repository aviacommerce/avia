defmodule Snitch.Data.Model.StateZone do
  @moduledoc """
  StateZone API
  """
  use Snitch.Data.Model
  use Snitch.Tools.Helper.Zone

  import Ecto.Query

  alias Snitch.Tools.Helper.Zone, as: ZH
  alias Snitch.Data.Schema.{StateZoneMember, Zone, State}

  @doc """
  Creates a new state `Zone` whose members are `state_ids`.

  `state_ids` is a list of primary keys of the `Snitch.Data.Schema.StateZoneMember`s that
  make up this zone. Duplicate IDs are ignored.

  ## Note
  The list of `StateZoneMember.t` is put in `zone.members`.
  """
  @spec create(String.t(), String.t(), [non_neg_integer]) :: term
  def create(name, description, state_ids) do
    zone_params = %{name: name, description: description, zone_type: "S"}
    zone_changeset = Zone.create_changeset(%Zone{}, zone_params)
    multi = ZH.creation_multi(zone_changeset, state_ids)

    case Repo.transaction(multi) do
      {:ok, %{zone: zone, members: members}} -> {:ok, %{zone | members: members}}
      error -> error
    end
  end

  @spec delete(non_neg_integer | Zone.t()) ::
          {:ok, Zone.t()} | {:error, Ecto.Changeset.t()} | {:error, :not_found}
  def delete(id_or_instance) do
    QH.delete(Zone, id_or_instance, Repo)
  end

  @spec get(map | non_neg_integer) :: Zone.t() | nil
  def get(query_fields_or_primary_key) do
    QH.get(Zone, query_fields_or_primary_key, Repo)
  end

  @spec get_all() :: [Zone.t()]
  def get_all, do: Repo.all(from(z in Zone, where: z.zone_type == "S"))

  @doc """
  Returns the list of `State` IDs that make up this zone.
  """
  @spec member_ids(Zone.t()) :: Zone.t()
  def member_ids(zone) do
    query = from(s in StateZoneMember, where: s.zone_id == ^zone.id, select: s.state_id)
    Repo.all(query)
  end

  @doc """
  Returns the list of `State` structs that make up this zone
  """
  @spec members(Zone.t()) :: Zone.t()
  def members(zone) do
    query =
      from(
        s in State,
        join: m in StateZoneMember,
        on: m.state_id == s.id,
        where: m.zone_id == ^zone.id
      )

    Repo.all(query)
  end

  @doc """
  Updates Zone params and sets the members as per `new_state_ids`.

  This replaces the old members with the new ones. Duplicate IDs in the list are
  ignored.

  ## Note
  The `zone.members` is set to `nil`!
  """
  @spec update(Zone.t(), map, [non_neg_integer]) :: {:ok, Zone.t()} | {:error, Ecto.Changeset.t()}
  def update(zone, zone_params, new_state_ids) do
    zone_changeset = Zone.update_changeset(zone, zone_params)
    multi = ZH.update_multi(zone, zone_changeset, new_state_ids)

    case Repo.transaction(multi) do
      {:ok, %{zone: zone}} -> {:ok, %{zone | members: nil}}
      error -> error
    end
  end

  def remove_members_query(to_be_removed, zone) do
    from(m in StateZoneMember, where: m.state_id in ^to_be_removed and m.zone_id == ^zone.id)
  end

  @doc """
  Returns `StateZoneMember` changesets for given `state_ids` for `state_zone` as a stream.
  """
  @spec member_changesets([non_neg_integer], Zone.t()) :: Enumerable.t()
  def member_changesets(state_ids, state_zone) do
    state_ids
    |> Stream.uniq()
    |> Stream.map(
      &StateZoneMember.create_changeset(%StateZoneMember{}, %{
        state_id: &1,
        zone_id: state_zone.id
      })
    )
  end

  @doc """
  Returns a query to fetch the state zones shared by (aka. common to) given
  `state_id`s.
  """
  @spec common_zone_query(non_neg_integer, non_neg_integer) :: Ecto.Query.t()
  def common_zone_query(state_a_id, state_b_id) do
    from(
      szm_a in StateZoneMember,
      join: szm_b in StateZoneMember,
      join: z in Zone,
      on: szm_a.zone_id == szm_b.zone_id and szm_a.zone_id == z.id,
      where: szm_a.state_id == ^state_a_id and szm_b.state_id == ^state_b_id,
      select: z
    )
  end
end
