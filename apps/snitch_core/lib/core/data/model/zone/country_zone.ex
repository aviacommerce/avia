defmodule Snitch.Data.Model.CountryZone do
  @moduledoc """
  CountryZone API
  """
  use Snitch.Data.Model

  import Ecto.Query

  alias Ecto.Multi
  alias Snitch.Data.Schema.{CountryZoneMember, Zone, Country}

  @doc """
  Creates a new country `Zone` whose members are `country_ids`.

  `country_ids` is a list of primary keys of the `Snitch.Data.Schema.Country`s that
  make up this zone. Duplicate IDs are ignored.
  """
  @spec create(String.t(), String.t(), [non_neg_integer]) :: term
  def create(name, description, country_ids) do
    zone_params = %{name: name, description: description, zone_type: "C"}
    zone_changeset = Zone.changeset(%Zone{}, zone_params, :create)

    Multi.new()
    |> Multi.insert(:zone, zone_changeset)
    |> Multi.run(:members, fn %{zone: zone} -> insert_members(country_ids, zone) end)
    |> Repo.transaction()
    |> case do
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
  def get_all, do: Repo.all(from(z in Zone, where: z.zone_type == "C"))

  @doc """
  Returns the list of `Country` IDs that make up this zone.
  """
  @spec member_ids(non_neg_integer) :: [non_neg_integer]
  def member_ids(zone_id) do
    query = from(m in CountryZoneMember, where: m.zone_id == ^zone_id, select: m.country_id)
    Repo.all(query)
  end

  @doc """
  Returns the list of `Country` structs that make up this zone.
  """
  @spec members(non_neg_integer) :: [Country.t()]
  def members(zone_id) do
    query =
      from(
        c in Country,
        join: m in CountryZoneMember,
        on: m.country_id == c.id,
        where: m.zone_id == ^zone_id
      )

    Repo.all(query)
  end

  @doc """
  Updates Zone params and sets the members as per `new_country_ids`.

  This replaces the old members with the new ones. Duplicate IDs in the list are
  ignored.
  """
  @spec update(String.t(), String.t(), [non_neg_integer]) ::
          {:ok, Zone.t()} | {:error, Ecto.Changeset.t()}
  def update(zone, zone_params, new_country_ids) do
    zone_changeset = Zone.changeset(zone, zone_params, :update)

    old_members = MapSet.new(member_ids(zone.id))
    new_members = MapSet.new(new_country_ids)
    added = set_difference(new_members, old_members)
    removed = set_difference(old_members, new_members)

    delete_query =
      from(m in CountryZoneMember, where: m.country_id in ^removed and m.zone_id == ^zone.id)

    deletions_multi =
      if length(removed) > 0 do
        Multi.delete_all(%Multi{}, :removed, delete_query)
      else
        Multi.new()
      end

    Multi.new()
    |> Multi.update(:zone, zone_changeset)
    |> Multi.run(:added, fn _ -> insert_members(added, zone) end)
    |> Multi.append(deletions_multi)
    |> Repo.transaction()
    |> case do
      {:ok, %{zone: zone}} -> {:ok, zone}
      error -> error
    end
  end

  defp insert_members(country_ids, zone) do
    country_ids
    |> Stream.uniq()
    |> Stream.map(
      &CountryZoneMember.changeset(
        %CountryZoneMember{},
        %{country_id: &1, zone_id: zone.id},
        :create
      )
    )
    |> Stream.map(&Repo.insert/1)
    |> Enum.reduce_while({:ok, []}, fn
      {:ok, member}, {:ok, acc} -> {:cont, {:ok, [member | acc]}}
      changeset, _acc -> {:halt, changeset}
    end)
  end

  defp set_difference(a, b) do
    a
    |> MapSet.difference(b)
    |> MapSet.to_list()
  end
end
