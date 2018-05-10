defmodule Snitch.Data.Model.CountryZone do
  @moduledoc """
  CountryZone API
  """
  use Snitch.Data.Model
  use Snitch.Tools.Helper.Zone

  import Ecto.Query

  alias Snitch.Data.Schema.{CountryZoneMember, Zone, Country}
  alias Snitch.Tools.Helper.Zone, as: ZH

  @doc """
  Creates a new country `Zone` whose members are `country_ids`.

  `country_ids` is a list of primary keys of the `Snitch.Data.Schema.CountryZoneMember`s that
  make up this zone. Duplicate IDs are ignored.

  ## Note
  The list of `CountryZoneMember.t` is put in `zone.members`.
  """
  @spec create(String.t(), String.t(), [non_neg_integer]) :: term
  def create(name, description, country_ids) do
    zone_params = %{name: name, description: description, zone_type: "C"}
    zone_changeset = Zone.create_changeset(%Zone{}, zone_params)
    multi = ZH.creation_multi(zone_changeset, country_ids)

    case Repo.transaction(multi) do
      {:ok, %{zone: zone, members: members}} -> {:ok, struct(zone, members: members)}
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
  def get_all, do: Repo.all(from(z in Zone, where: z.zone_type == "C"))

  @doc """
  Returns the list of `Country` IDs that make up this zone.
  """
  @spec member_ids(Zone.t()) :: [non_neg_integer]
  def member_ids(%Zone{} = zone) do
    query = from(m in CountryZoneMember, where: m.zone_id == ^zone.id, select: m.country_id)
    Repo.all(query)
  end

  @doc """
  Returns the list of `Country` structs that make up this zone.
  """
  @spec members(Zone.t()) :: [Country.t()]
  def members(%Zone{} = zone) do
    query =
      from(
        c in Country,
        join: m in CountryZoneMember,
        on: m.country_id == c.id,
        where: m.zone_id == ^zone.id
      )

    Repo.all(query)
  end

  @doc """
  Updates Zone params and sets the members as per `new_country_ids`.

  This replaces the old members with the new ones. Duplicate IDs in the list are
  ignored.

  ## Note
  The `zone.members` is set to `nil`!
  """
  @spec update(Zone.t(), map, [non_neg_integer]) :: {:ok, Zone.t()} | {:error, Ecto.Changeset.t()}
  def update(%Zone{} = zone, zone_params, new_country_ids) do
    zone_changeset = Zone.update_changeset(zone, zone_params)
    multi = ZH.update_multi(zone, zone_changeset, new_country_ids)

    case Repo.transaction(multi) do
      {:ok, %{zone: zone}} -> {:ok, zone}
      error -> error
    end
  end

  @doc """
  Returns a query to bulk remove `CountryZoneMember` records as per `to_be_removed` in `zone`.
  """
  @spec remove_members_query([non_neg_integer], Zone.t()) :: Ecto.Query.t()
  def remove_members_query(to_be_removed, zone) do
    from(
      m in CountryZoneMember,
      where: m.country_id in ^to_be_removed and m.zone_id == ^zone.id
    )
  end

  @doc """
  Returns `CountryZoneMember` changesets for given `country_ids` for `country_zone` as a stream.
  """
  @spec member_changesets([non_neg_integer], Zone.t()) :: Enumerable.t()
  def member_changesets(country_ids, %Zone{} = country_zone) do
    country_ids
    |> Stream.uniq()
    |> Stream.map(
      &CountryZoneMember.create_changeset(%CountryZoneMember{}, %{
        country_id: &1,
        zone_id: country_zone.id
      })
    )
  end

  @doc """
  Returns a query to fetch the country zones shared by (aka. common to) given
  `country_id`s.
  """
  @spec common_zone_query(non_neg_integer, non_neg_integer) :: Ecto.Query.t()
  def common_zone_query(country_a_id, country_b_id) do
    from(
      czm_a in CountryZoneMember,
      join: czm_b in CountryZoneMember,
      join: z in Zone,
      on: czm_a.zone_id == czm_b.zone_id and czm_a.zone_id == z.id,
      where: czm_a.country_id == ^country_a_id and czm_b.country_id == ^country_b_id,
      select: z
    )
  end
end
