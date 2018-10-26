defmodule Snitch.Data.Schema.Promotion do
  @moduledoc """
  Models promotions.

  Allows creation of PromoCodes and uses a set of rules to apply set of
  actions on the payload to provide discounts.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.PromotionRule

  @type t :: %__MODULE__{}
  @match_policy ~w(all any)s

  schema "snitch_promotions" do
    field(:code, :string)
    field(:description, :string)
    field(:starts_at, :utc_datetime)
    field(:expires_at, :utc_datetime)
    field(:usage_limit, :integer, default: 0)
    field(:match_policy, :string, default: "all")
    field(:active, :boolean, default: false)
    embeds_many(:rules, PromotionRule)
    # field(:actions, {:array, :map}, default: [])
    # TODO add code for actions once it is done for rulestry with rules first.

    timestamps()
  end

  @required_fields ~w(code)a
  @optional_fields ~w(description starts_at expires_at usage_limit match_policy
    active code)a

  @create_fields @optional_fields ++ @required_fields

  @doc """
  Returns a create changeset for `Promotion.t()`.
  """
  def create_changeset(%__MODULE__{} = promotion, params) do
    promotion
    |> cast(params, @create_fields)
    |> common_changeset()
  end

  @doc """
  Returns a create changeset for `Promotion.t()`.
  """
  def update_changeset(%__MODULE__{} = promotion, params) do
    promotion
    |> cast(params, @create_fields)
    |> common_changeset()
  end

  def rule_update_changeset(%__MODULE__{} = promotion, params) do
    promotion
    |> cast(params, @create_fields)
    |> cast_embed(:rules, with: &PromotionRule.changeset/2)
    |> common_changeset()
  end

  def action_update_changeset(%__MODULE__{} = promotion, params) do
    promotion
    |> cast(params, @create_fields)
    ## Change this once action is added
    |> cast_embed(:rules)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> validate_required(@required_fields)
    |> validate_future_date(:expires_at)
    |> validate_inclusion(:match_policy, @match_policy)
    |> unique_constraint(:code)
  end
end
