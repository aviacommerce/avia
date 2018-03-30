defmodule Snitch.Tools.Helper.Zone do
  @moduledoc """
  Helper functions to bulk insert/update country/state zone's members.
  """

  alias Ecto.Multi
  alias Snitch.Repo
  alias Snitch.Data.Schema.Zone
  alias Snitch.Data.Model.{StateZone, CountryZone}

  @doc """
  Returns a `Multi.t` to bulk insert zone members for `zone_changeset`

  * `zone_changeset` is the state/country `Snitch.Data.Schema.Zone` changeset.
  * `member_ids` is the list of country/state primary keys which are to be inserted.
  """
  @spec creation_multi(Ecto.Changeset.t(), [non_neg_integer]) :: Multi.t()
  def creation_multi(zone_changeset, member_ids) do
    Multi.new()
    |> Multi.insert(:zone, zone_changeset)
    |> Multi.run(:members, fn %{zone: zone} ->
      multi_run_insert_members(member_ids, zone)
    end)
  end

  def update_multi(zone, zone_changeset, new_member_ids) do
    %{added: added, removed: removed} = update_diff(new_member_ids, zone)

    Multi.new()
    |> Multi.update(:zone, zone_changeset)
    |> Multi.run(:added, fn _ ->
      multi_run_insert_members(added, zone)
    end)
    |> Multi.append(remove_members_multi(removed, zone))
  end

  @spec set_difference(MapSet.t(), MapSet.t()) :: list
  def set_difference(%MapSet{} = a, %MapSet{} = b) do
    a
    |> MapSet.difference(b)
    |> MapSet.to_list()
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
    Multi.delete_all(%Multi{}, :removed, removal_query)
  end

  defp update_diff(new_member_ids, current_zone) do
    zone_module = get_zone_module(current_zone)

    old_members =
      current_zone.id
      |> zone_module.member_ids()
      |> MapSet.new()

    new_members = MapSet.new(new_member_ids)
    added = set_difference(new_members, old_members)
    removed = set_difference(old_members, new_members)
    %{added: added, removed: removed}
  end

  defp get_zone_module(%Zone{zone_type: "S"}), do: StateZone
  defp get_zone_module(%Zone{zone_type: "C"}), do: CountryZone
end
