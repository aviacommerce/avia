defmodule Snitch.Tools.Cache do
  @moduledoc """
  Helper for caching data
  """

  @cache_name :avia_cache

  @doc """
  Fetches the data
  * from cache if exists.
  * from the callback function `fun` returning the data
  """
  def get(cache_key, {fun, args}, expiry \\ :timer.hours(2)) do
    with {:ok, value} <- Cachex.get(@cache_name, cache_key),
         false <- is_nil(value) do
      value
    else
      _ ->
        result = apply(fun, args)
        Cachex.put(@cache_name, cache_key, result, ttl: expiry)
        result
    end
  end
end
