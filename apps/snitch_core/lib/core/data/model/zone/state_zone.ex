defmodule Snitch.Data.Model.StateZone do
  @moduledoc """
  StateZone API
  """
  use Snitch.Data.Model

  import Ecto.Query
  import Snitch.Tools.Helper.Zone

  alias Snitch.Data.Schema.{StateZoneMember, Zone, State}

  @doc """
  Creates a new state `Zone` whose members are `state_ids`.

  `state_ids` is a list of primary keys of the `Snitch.Data.Schema.State`s that
  make up this zone. Duplicate IDs are ignored.
  """
  @spec create(String.t(), String.t(), [non_neg_integer]) :: term
  def create(name, description, state_ids) do
    zone_params = %{name: name, description: description, zone_type: "S"}
    zone_changeset = Zone.create_changeset(%Zone{}, zone_params)
    multi = creation_multi(zone_changeset, state_ids)

    case Repo.transaction(multi) do
      {:ok, %{zone: zone}} -> {:ok, zone}
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
  @spec member_ids(non_neg_integer) :: [non_neg_integer]
  def member_ids(zone_id) do
    query = from(s in StateZoneMember, where: s.zone_id == ^zone_id, select: s.state_id)
    Repo.all(query)
  end

  @doc """
  Returns the list of `State` structs that make up this zone.
  """
  @spec members(non_neg_integer) :: [State.t()]
  def members(zone_id) do
    query =
      from(
        s in State,
        join: m in StateZoneMember,
        on: m.state_id == s.id,
        where: m.zone_id == ^zone_id
      )

    Repo.all(query)
  end

  @doc """
  Updates Zone params and sets the members as per `new_state_ids`.

  This replaces the old members with the new ones. Duplicate IDs in the list are
  ignored.
  """
  @spec update(String.t(), String.t(), [non_neg_integer]) ::
          {:ok, Zone.t()} | {:error, Ecto.Changeset.t()}
  def update(zone, zone_params, new_state_ids) do
    zone_changeset = Zone.update_changeset(zone, zone_params)
    multi = update_multi(zone, zone_changeset, new_state_ids)

    case Repo.transaction(multi) do
      {:ok, %{zone: zone}} -> {:ok, zone}
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
end
