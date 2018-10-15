defmodule Snitch.Core.Tools.MultiTenancy.MultiQuery do
  @moduledoc """
    Alternative Ecto.Multi query builder to support multi tenancy.
    By default, all functions will insert :prefix in options.
  """

  import Snitch.Core.Tools.MultiTenancy.Helper

  defmulti(:insert, [:arg1, :arg2, :arg3], :append)
  defmulti(:update, [:arg1, :arg2, :arg3], :append)
  defmulti(:update_all, [:arg1, :arg2, :arg3, :arg4], :append)
  defmulti(:delete_all, [:arg1, :arg2, :arg3], :append)
end
