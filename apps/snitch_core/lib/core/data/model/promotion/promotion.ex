defmodule Snitch.Data.Model.Promotion do
  @moduledoc """
  APIs for Promotion.
  """

  use Snitch.Data.Model
  import Ecto.Changeset

  alias Snitch.Core.Tools.MultiTenancy.Repo
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
  Adds the rules for existing promotion.

  Expects the promotion struct for which the rule has to be added and
  a list or rules.

  ## Caution!
  The rules of a promotion are casted with `cast_embed` and invokes the
  `on_replace: delete` check. Hence, if the supplied `rules` list does not
  include previously added rules then they would be deleted.

  If initially the prmotion struct had rules
  ```
  Promotion{
    rules: [
      %Snitch.Data.Schema.PromotionRule{
       id: "6664d057-c61b-4481-8c61-3b29d10450ab",
       module: Snitch.Data.Schema.PromotionRule.OrderTotal,
       name: "order total",
       preferences: %{lower_range: #Decimal<10>, upper_range: #Decimal<1000>}
     }
    ]
  }
  ```
  Then the rule list should have the old rule along with new ones.

  ```
    [
    %{
       module: Snitch.Data.Schema.PromotionRule.OrderTotal,
       name: "order total",
       preferences: %{lower_range: #Decimal<10>, upper_range: #Decimal<1000>}
     },
     %{another rule here}
    ]
  ```
  """
  @spec add_promo_rules(Promotion.t(), [map]) :: {:ok, Promotion.t()} | {:error, Promotion.t()}
  def add_promo_rules(promotion, rules) do
    params = %{rules: rules}
    changeset = Promotion.rule_update_changeset(promotion, params)

    case check_for_error_in_preference(changeset) do
      {:ok, changeset} ->
        Repo.update(changeset)

      {:error, _} = error ->
        error
    end
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
      :code.priv_dir(:snitch_core)
      |> Path.join("promotion_rule_manifest.yaml")
      |> YamlElixir.read_from_file()

    Enum.reduce(rules, %{}, fn rule, acc ->
      Map.merge(acc, rule)
    end)
  end

  ############################ Private Functions ####################

  defp check_for_error_in_preference(changeset) do
    {:ok, rules} = fetch_change(changeset, :rules)

    if Enum.any?(rules, fn rule_changeset ->
         {:ok, preference} = fetch_change(rule_changeset, :preferences)
         is_changeset?(preference)
       end) do
      {:error, changeset}
    else
      {:ok, changeset}
    end
  end

  defp is_changeset?(%Ecto.Changeset{}), do: true
  defp is_changeset?(_), do: false
end
