defmodule Snitch.Core.Tools.MultiTenancy.Repo do
  @moduledoc """
  Alternative Repo to support multi tenancy.
  By default, all functions will insert :prefix in options.
  """

  import Snitch.Core.Tools.MultiTenancy.Helper

  alias Snitch.Repo

  defrepo(:get, [:arg1, :arg2], :append)
  defrepo(:get!, [:arg1, :arg2], :append)
  defrepo(:get_by, [:arg1, :arg2], :append)
  defrepo(:get_by!, [:arg1, :arg2], :append)
  defrepo(:one, [:arg1], :append)
  defrepo(:one!, [:arg1], :append)
  defrepo(:insert!, [:arg1], :append)
  defrepo(:update, [:arg1], :append)
  defrepo(:update!, [:arg1], :append)
  defrepo(:update_all, [:arg1, :arg2], :append)
  defrepo(:delete, [:arg1], :append)
  defrepo(:delete_all, [:arg1], :append)
  defrepo(:aggregate, [:arg1, :arg2, :arg3], :append)

  defrepo(:load, [:arg1, :arg2], :pass)
  defrepo(:rollback, [:arg1], :pass)

  def insert(arg1, arg2 \\ []), do: Repo.insert(arg1, get_opts() ++ arg2)

  def all(arg1, arg2 \\ []), do: Repo.all(arg1, get_opts() ++ arg2)

  def insert_all(arg1, arg2, arg3 \\ []), do: Repo.insert_all(arg1, arg2, get_opts() ++ arg3)

  def preload(arg1, arg2, arg3 \\ []), do: Repo.preload(arg1, arg2, get_opts() ++ arg3)

  def transaction(arg1, arg2 \\ []), do: Repo.transaction(arg1, get_opts() ++ arg2)

  def set_tenant(tenant) do
    Process.put({__MODULE__, :prefix}, tenant)
    tenant
  end

  def get_opts do
    [
      prefix: get_prefix()
    ]
  end

  def get_prefix() do
    Process.get({__MODULE__, :prefix})
  end
end
