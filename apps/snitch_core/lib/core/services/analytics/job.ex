defmodule Snitch.Service.Analytics.Jobs do
  @moduledoc """
  Worker module for a Analytics.
  """

  alias Hydrus
  @behaviour Honeydew.Worker

  @doc """
  Initializes the worker
  """
  def init(_args) do
    {:ok, %{}}
  end

  @doc """
  Runs a task to create an event with the
  supplied params.
  """
  def run(args, _state) do
    Hydrus.create(args)
    :ok
  end
end
