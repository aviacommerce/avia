defmodule Snitch.Data.Model.Zone do
  @moduledoc """
  Helper functions to bulk insert/update country/state zone's members.
  """

  alias Ecto.Multi
  use Snitch.Data.Model
  alias Snitch.Data.Model.{CountryZone, StateZone}
  alias Snitch.Data.Schema.Zone
  alias Snitch.Core.Tools.MultiTenancy.MultiQuery
  import Ecto.Query

  defmacro __using__(_) do
    quote do
      model_name =
        __MODULE__
        |> Module.split()
        |> List.last()

      @doc """
      Fetches the member `Snitch.Data.Schema.#{model_name}Member.t` structs that
      make up this `zone`.

      The fetched structs are placed under the `:members` key.
      """
      @spec fetch_members(Zone.t()) :: Zone.t()
      def fetch_members(%Zone{} = zone) do
        struct(zone, members: members(zone))
      end
    end
  end

  @doc """
  Returns a `Multi.t` to bulk insert zone members for `zone_changeset`.

  * `zone_changeset` is the state/country `Zone` changeset.
  * `member_ids` is the list of country/state primary keys which are to be inserted.
  """

  def creation_multi(zone_changeset, []) do
    Multi.new()
    |> MultiQuery.insert(:zone, zone_changeset)
  end

  @spec creation_multi(Ecto.Changeset.t(), [non_neg_integer]) :: Multi.t()
  def creation_multi(zone_changeset, member_ids) do
    Multi.new()
    |> MultiQuery.insert(:zone, zone_changeset)
    |> Multi.run(:members, fn %{zone: zone} ->
      if member_ids != [] do
        multi_run_insert_members(member_ids, zone)
      end
    end)
  end

  @doc """
  Returns a `Multi.t` to update all zone members for `zone_changeset`.

  * `zone_changeset` is the state/country `Zone` changeset.
  * `member_ids` is the list of _desired_ country/state primary keys.
  """
  @spec update_multi(Zone.t(), Ecto.Changeset.t(), [non_neg_integer]) :: Multi.t()
  def update_multi(zone, zone_changeset, new_member_ids) do
    %{added: added, removed: removed} = update_diff(new_member_ids, zone)

    Multi.new()
    |> MultiQuery.update(:zone, zone_changeset)
    |> Multi.run(:added, fn _ ->
      multi_run_insert_members(added, zone)
    end)
    |> Multi.append(remove_members_multi(removed, zone))
  end

  def delete(id_or_instance) do
    QH.delete(Zone, id_or_instance, Repo)
  end

  defp multi_run_insert_members(member_ids, zone) do
    zone_module = get_zone_module(zone)

    member_ids
    |> zone_module.member_changesets(zone)
    |> Stream.map(&Repo.insert/1)
    |> Enum.reduce_while({:ok, []}, fn
      {:ok, member}, {:ok, acc} -> {:cont, {:ok, [member | acc]}}
      changeset, _acc -> {:halt, changeset}
    end)
  end

  defp remove_members_multi([], _), do: Multi.new()

  defp remove_members_multi(to_be_removed, zone) do
    zone_module = get_zone_module(zone)
    removal_query = zone_module.remove_members_query(to_be_removed, zone)
    MultiQuery.delete_all(%Multi{}, :removed, removal_query)
  end

  defp update_diff(new_member_ids, current_zone) do
    zone_module = get_zone_module(current_zone)

    old_members =
      current_zone
      |> zone_module.member_ids()
      |> Enum.map(&Integer.to_string/1)
      |> MapSet.new()

    new_members = new_member_ids |> get_new_members_mapset()
    added = set_difference(new_members, old_members)
    removed = set_difference(old_members, new_members)

    %{added: added, removed: removed}
  end

  defp get_new_members_mapset(new_member_ids) do
    case new_member_ids do
      nil -> MapSet.new()
      _ -> new_member_ids |> MapSet.new()
    end
  end

  defp get_zone_module(%Zone{zone_type: "S"}), do: StateZone
  defp get_zone_module(%Zone{zone_type: "C"}), do: CountryZone

  @spec set_difference(MapSet.t(), MapSet.t()) :: list
  defp set_difference(%MapSet{} = a, %MapSet{} = b) do
    a
    |> MapSet.difference(b)
    |> MapSet.to_list()
  end

  @spec members(Zone.t()) :: [Country.t()] | [State.t()]
  def members(%Zone{} = zone) do
    case zone.zone_type do
      "S" -> StateZone.members(zone)
      "C" -> CountryZone.members(zone)
    end
  end

  @spec member_ids(Zone.t()) :: Country.t() | State.t()
  def member_ids(%Zone{} = zone) do
    case zone.zone_type do
      "S" -> StateZone.member_ids(zone)
      "C" -> CountryZone.member_ids(zone)
    end
  end

  @spec get(map | non_neg_integer) :: Zone.t() | nil
  def get(id) when is_integer(id) do
    Zone
    |> where([z], z.id == ^id)
    |> Repo.all()
    |> List.first()
  end

  def get(id) when is_binary(id) do
    id = String.to_integer(id)
    get(id)
  end

  @doc """
  Returns a list of zones with the default zone as the first element
  of the list.
  """
  def get_all() do
    Zone
    |> order_by([z], desc: z.is_default)
    |> Repo.all()
  end

  @spec formatted_list() :: [{String.t(), non_neg_integer}]
  def formatted_list do
    Zone
    |> order_by([s], asc: s.name)
    |> select([s], {s.name, s.id})
    |> Repo.all()
  end
end
