defmodule Snitch.Data.Schema.Promotion do
  @moduledoc """
  Models coupon based `promotions`.

  Allows creation of PromoCodes and uses a set of rules to apply set of
  actions on the payload to provide discounts.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{PromotionRule, PromotionAction}

  @type t :: %__MODULE__{}
  @match_policy ~w(all any)s

  schema "snitch_promotions" do
    field(:code, :string)
    field(:name, :string)
    field(:description, :string)
    field(:starts_at, :utc_datetime, default: DateTime.utc_now())
    field(:expires_at, :utc_datetime)
    field(:usage_limit, :integer, default: 0)
    field(:current_usage_count, :integer, default: 0)
    field(:match_policy, :string, default: "all")
    field(:active?, :boolean, default: false)

    # associations
    has_many(:rules, PromotionRule, on_delete: :delete_all)

    # shouldn't delete actions they are being used for tracking
    # adjustments later on.
    has_many(:actions, PromotionAction, on_delete: :nilify_all)

    timestamps()
  end

  @required_fields ~w(code name)a
  @optional_fields ~w(description starts_at expires_at usage_limit match_policy
    active? code)a

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
  Returns a changeset to update the rules for a promotion.

  ### Note
  - The function uses `cast_assoc` for managing associations so
    rules specified by `cast_assoc` applies.
    __See__
    `Ecto.Changeset.cast_assoc(changeset, name, opts \\ [])`
  - The `:rules` association needs to be preloaded before calling
    update `action`.
  """
  def rule_update_changeset(%__MODULE__{} = promotion, params) do
    promotion
    |> cast(params, @create_fields)
    |> common_changeset()
    |> cast_assoc(:rules, with: &PromotionRule.changeset/2)
  end

  @doc """
  Returns a changeset to update the actions for a promotion.

  ### Note
  - The function uses `cast_assoc` for managing associations so
    rules specified by `cast_assoc` applies.
    __See__
    `Ecto.Changeset.cast_assoc(changeset, name, opts \\ [])`
  - The `:actions` association needs to be preloaded before calling
    update `action`.
  - `on_replace: :nilify_all` is being used for `actions` because
    in case a promotion is updated and the action is removed then it should
    not be removed as it keeps track of adjustments against the order.
  """
  def action_update_changeset(%__MODULE__{} = promotion, params) do
    promotion
    |> cast(params, @create_fields)
    |> common_changeset()
    |> cast_assoc(:actions, with: &PromotionAction.changeset/2)
  end

  @doc """
  Returns an update changeset for `Promotion.t()`.
  """
  def update_changeset(%__MODULE__{} = promotion, params) do
    promotion
    |> cast(params, @create_fields)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> validate_required(@required_fields)
    |> validate_future_date(:expires_at)
    |> validate_inclusion(:match_policy, @match_policy)
    |> validate_starts_at_with_expiry()
    |> unique_constraint(:code)
  end

  # checks if `expires_at` is after `starts_at`
  defp validate_starts_at_with_expiry(%Ecto.Changeset{valid?: true} = changeset) do
    with {:ok, starts_at} <- fetch_change(changeset, :starts_at),
         {:ok, expires_at} <- fetch_change(changeset, :expires_at) do
      if DateTime.compare(expires_at, starts_at) == :gt do
        changeset
      else
        add_error(changeset, :expires_at, "expires_at should be after starts_at")
      end
    else
      :error ->
        changeset
    end
  end

  defp validate_starts_at_with_expiry(changeset), do: changeset
end
