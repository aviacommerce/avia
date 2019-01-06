defmodule Snitch.Data.Schema.Promotion do
  @moduledoc """
  Models coupon based `promotions`.

  Allows creation of PromoCodes and uses a set of rules to apply set of
  actions on the payload to provide discounts.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{PromotionAction, PromotionRule}
  alias Snitch.Tools.EctoType.UnixTimestamp

  @typedoc """
  Represents a promotion struct.

  Fields
  - `code`: Unique code to identify the promotion. Made available to user for
    applying a promotion.
  - `name`: A kind of label to identify the `promotion` with.
  - `starts_at`: The time at which the promotion will start.
  - `expires_at`: The time at which the promotion will end.
  - `usage_limit`: This is used to set the number of times this code can be used
     thoroughout it's life for all the users.
  - `current_usage_count`: Tracks the number of times the promotion has been used.
  - `match_policy`: The policy used while checking for rules of an action, an
    `all` policy means all the rules should be satisfied whereas an `any` policy
    would require any one of them to be satisified.
  `active?`: Used to mark the promotion active or inactive.
  `archived_at`: This is used to check if a promotion archived. An archived
    promotion means it is no longer active and is present only for record.
  """

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
    field(:archived_at, UnixTimestamp, default: 0)

    # associations

    has_many(:rules, PromotionRule, on_replace: :delete, on_delete: :delete_all)
    has_many(:actions, PromotionAction, on_replace: :delete, on_delete: :delete_all)

    timestamps()
  end

  @required_fields ~w(code name)a
  @optional_fields ~w(description starts_at expires_at usage_limit match_policy
    active? archived_at)a

  @create_fields @optional_fields ++ @required_fields

  @doc """
  Returns a create changeset for `Promotion.t()`.
  """
  def create_changeset(%__MODULE__{} = promotion, params) do
    promotion
    |> cast(params, @create_fields)
    |> common_changeset()
    |> cast_assoc(:rules, with: &PromotionRule.changeset/2)
    |> cast_assoc(:actions, with: &PromotionAction.changeset/2)
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
    |> cast_assoc(:rules, with: &PromotionRule.changeset/2)
    |> cast_assoc(:actions, with: &PromotionAction.changeset/2)
  end

  defp common_changeset(changeset) do
    changeset
    |> validate_required(@required_fields)
    |> validate_future_date(:expires_at)
    |> validate_inclusion(:match_policy, @match_policy)
    |> validate_starts_at_before_expiry()
    |> unique_constraint(:code,
      name: :unique_promotion_code,
      message: "has already been taken"
    )
  end

  # checks if `expires_at` is after `starts_at`
  defp validate_starts_at_before_expiry(%Ecto.Changeset{valid?: true} = changeset) do
    handle_start_and_expiry_date(
      changeset,
      get_change(changeset, :starts_at),
      get_change(changeset, :expires_at)
    )
  end

  defp validate_starts_at_before_expiry(changeset), do: changeset

  defp handle_start_and_expiry_date(changeset, nil, nil) do
    changeset
  end

  defp handle_start_and_expiry_date(changeset, nil = _starts_at, expires_at) do
    {:data, date} = fetch_field(changeset, :starts_at)

    handle_date_related_changeset(
      changeset,
      date,
      expires_at,
      :expires_at,
      "expires_at should be after starts_at"
    )
  end

  defp handle_start_and_expiry_date(changeset, starts_at, nil = _expires_at) do
    {:data, date} = fetch_field(changeset, :expires_at)

    handle_date_related_changeset(
      changeset,
      starts_at,
      date,
      :starts_at,
      "starts_at should be before expires_at"
    )
  end

  defp handle_start_and_expiry_date(changeset, starts_at, expires_at) do
    handle_date_related_changeset(
      changeset,
      starts_at,
      expires_at,
      :expires_at,
      "expires_at should be after starts_at"
    )
  end

  defp handle_date_related_changeset(changeset, starts_at, expires_at, key, error) do
    if DateTime.compare(expires_at, starts_at) == :gt do
      changeset
    else
      add_error(changeset, key, error)
    end
  end
end
