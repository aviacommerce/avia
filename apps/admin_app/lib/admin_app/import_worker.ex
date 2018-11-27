defmodule Avia.Etsy.ImportWorker do
  @moduledoc """
  Worker module for a Import.
  """

  alias Avia.Etsy.Importer

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
  def run(id, _state) do
    Importer.import()
    :ok
  end
end
