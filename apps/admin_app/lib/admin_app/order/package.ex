defmodule AdminApp.PackageContext do
  import Ecto.Query
  alias Snitch.Data.Schema.Package
  alias Snitch.Core.Tools.MultiTenancy.Repo

  def update_packages(state, order_id) do
    query =
      from(
        package in Package,
        where: package.order_id == ^order_id
      )

    case Repo.update_all(query, set: [state: state]) do
      {0, _} ->
        {:error, "Update failed"}

      _ ->
        {:ok, "updated"}
    end
  end
end
