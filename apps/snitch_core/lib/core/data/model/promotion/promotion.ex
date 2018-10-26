defmodule Snitch.Data.Model.Promotion do
  @moduledoc """
  APIs for Promotion.
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.Promotion

  @doc """
  Creates a Promotion with the supplied `params`.

  Can be used to create all the fields except the `rules` and `actions`.
  ### See
  `Promotion`
  """
  @spec create(map) :: {:ok, Promotion.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    QH.create(Promotion, params, Repo)
  end

  @doc """
  Updates an existing Promotion with the supplied `params`.

  Can be used to update all the fields except `rules` and `actions`.
  """
  @spec update(map, Promotion.t() | nil) ::
          {:ok, Promotion.t()}
          | {:error, Ecto.Changeset.t()}
  def update(params, instance \\ nil) do
    QH.update(Promotion, params, instance, Repo)
  end

  @doc """
  Deletes a Promotion.

  Takes as input the `instance` or `id` of the Promotion to be deleted.
  """
  @spec delete(Promotion.t() | integer) ::
          {:ok, Promotion.t()}
          | {:error, Ecto.Changeset.t()}
  def delete(id) do
    QH.delete(Promotion, id, Repo)
  end

  @doc """
  Returns a Promotion.

  Takes as input the 'id'.
  """
  @spec get(integer) :: Promotion.t() | nil
  def get(id) do
    QH.get(Promotion, id, Repo)
  end

  @doc """
  Returns a `list` of promotions.
  """
  @spec get_all() :: [Promotion.t()]
  def get_all() do
    Repo.all(Promotion)
  end

  @doc """
  Loads all the rule names alongwith module name.

  Returns a list in the format [{name, module_name}]
  """
  def load_promotion_manifest do
    {:ok, rules} =
      File.cwd!()
      |> Path.join("/priv/promotion_rule_manifest.yaml")
      |> YamlElixir.read_from_file()

    Enum.reduce(rules, %{}, fn rule, acc ->
      Map.merge(acc, rule)
    end)
  end
end
