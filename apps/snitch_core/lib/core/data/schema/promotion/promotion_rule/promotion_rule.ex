defmodule Snitch.Data.Schema.PromotionRule do
  @moduledoc """
  Models `rules` for a promotion.

  __Promotion rules__ are a set of conditions that the `payload`
  has to meet, to be eligible for the promotion.
  """
  use Snitch.Data.Schema
  alias Snitch.Data.Schema.Promotion
  alias Snitch.Tools.Validations

  @type t :: %__MODULE__{}

  @doc """
  Adds an overridable `line_item_actionable?` function to all the modules
  adopting the `__MODULE__` behavour.

  By default `line_item_actionable?` returns true, it's behaviour can be
  modified as per need by the module adopting it.
  """
  defmacro __using__(_opts) do
    quote do
      @behaviour Snitch.Data.Schema.PromotionRule

      def line_item_actionable?(_line_item, _rule) do
        true
      end

      defoverridable(line_item_actionable?: 2)
    end
  end

  @doc """
  Checks if the supplied order meets the condition specified
  in the supplied rule.
  """
  @callback eligible(order :: Order.t(), rule_data :: map) :: true | {false, reason :: String.t()}

  @doc """
  Returns the name of the rule.
  """
  @callback rule_name() :: name :: String.t()

  @doc """
  Checks whether the `line_item` is actionable or not.

  All the rules adopting the `PromotionRule` behaviour can implement their own
  custom logic for the function. By default the function returns true
  for all the line_items.

  ### Note
  Any rule which anyhow will affect the action on `line_item` should implement
  this function.
  """
  @callback line_item_actionable?(
              line_item :: LineItem.t(),
              rule :: PromotionRule.t()
            ) :: boolean()

  schema "snitch_promotion_rules" do
    field(:name, :string)
    field(:module, PromotionRuleEnum)
    field(:preferences, :map)

    # associations
    belongs_to(:promotion, Promotion, on_replace: :delete)

    timestamps()
  end

  @required_params ~w(name module preferences)a
  @optional_params ~w(promotion_id)a
  @create_params @required_params ++ @optional_params

  @doc """
  Returns a changeset for `PromotionRule.t()`.

  This function has been explicitly created to be used with while creating
  `promotion rule` with a promotion via the `cast_assoc` function.
  ### See
  `Promotion.rule_update_changeset/2`

  To create rule explicitly without `cast_assoc` use `create_changeset/2`.
  """
  def changeset(%__MODULE__{} = rule, params) do
    rule
    |> cast(params, @create_params)
    |> validate_required(@required_params)
    |> common_changeset()
  end

  def create_changeset(%__MODULE__{} = rule, params) do
    rule
    |> cast(params, @create_params)
    |> validate_required([:promotion_id | @required_params])
    |> common_changeset()
  end

  ############################ private functions ######################

  defp common_changeset(changeset) do
    changeset
    |> unique_constraint(:name)
    |> foreign_key_constraint(:promotion_id)
    |> Validations.validate_embedded_data(:module, :preferences)
  end
end
