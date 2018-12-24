defmodule Snitch.Data.Model.Adjustment do
  @moduledoc """
  Exposes functions for adjustments.
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.Adjustment

  @doc """
  Creates an Adjustment with the supplied `params`.
  """
  @spec create(map) :: {:ok, Adjustment.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    QH.create(Adjustment, params, Repo)
  end

  @doc """
  Updates an existing Adjustment with supplied `params`.
  """
  @spec update(map, Adjustment.t() | nil) ::
          {:ok, Adjustment.t()}
          | {:error, Ecto.Changeset.t()}
  def update(params, instance \\ nil) do
    QH.update(Adjustment, params, instance, Repo)
  end
end
