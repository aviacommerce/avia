defmodule Snitch.Data.Model.TaxZone do
  @moduledoc """
  Exposes API for tax zone.
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.TaxZone

  @doc """
  Creates a `tax_zone` with the supplied params.

  Expected keys in params:
  - `*name`: name of the tax zone.
  - `is_active?`: whether the tax zone should be active or not.
  - `*zone_id`: zone with which it would be associated.

  > * are required fields.

  >`Zones` with which a tax zone is associated as such have no restrictions on their
    members while they are created. However, tax zones which can also be of type state
    or country depending on the zone they are associated with, need to have members
    mutually exclusive of each other. Also, two tax zones can not be associated with the
    same zone.
  """
  @spec create(map) ::
          {:ok, TaxZone.t()}
          | {:error, Ecto.Changeset.t()}
  def create(params) do
    QH.create(TaxZone, params, Repo)
  end

  @spec update(TaxZone.t(), map) ::
          {:ok, TaxZone.t()}
          | {:error, Ecto.Changeset.t()}
  def update(tax_zone, params) do
    QH.update(TaxZone, params, tax_zone, Repo)
  end

  @spec get(non_neg_integer) :: {:ok, TaxZone.t()} | {:error, String.t()}
  def get(id) do
    QH.get(TaxZone, id, Repo)
  end

  @spec get_all() :: [TaxZone.t()]
  def get_all() do
    Repo.all(TaxZone)
  end
end
