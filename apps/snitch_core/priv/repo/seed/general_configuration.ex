defmodule Snitch.Seed.GeneralConfiguration do
  alias Snitch.Data.Schema.GeneralConfiguration, as: GCSchema
  alias Snitch.Core.Tools.MultiTenancy.Repo

  def seed!() do
    Repo.delete_all(GCSchema)
    %GCSchema{currency: "USD"} |> Repo.insert()
  end
end
