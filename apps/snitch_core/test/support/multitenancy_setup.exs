defmodule Snitch.Core.MultiTenancy.TestSetup do
  tenant =
    System.argv()
    |> List.first()

  Application.put_env(:snitch, :multitenancy_test, tenant: tenant)
  Triplex.create(tenant)
end
