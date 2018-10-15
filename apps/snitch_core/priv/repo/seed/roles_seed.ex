defmodule Snitch.Seed.Role do
  @moduledoc false
  @roles %{"user" => "normal user role", "admin" => "can manage everything"}

  alias Snitch.Data.Schema.Role
  alias Snitch.Core.Tools.MultiTenancy.Repo

  require Logger

  def seed do
    data =
      Enum.reduce(@roles, [], fn {role, description}, acc ->
        value =
          %{}
          |> Map.put(:name, role)
          |> Map.put(:description, description)
          |> Map.put(:inserted_at, DateTime.utc_now())
          |> Map.put(:updated_at, DateTime.utc_now())

        [value | acc]
      end)

    {count, _} = Repo.insert_all(Role, data, on_conflict: :nothing, conflict_target: :name)
    Logger.info("Inserted #{count} roles")
  end
end
