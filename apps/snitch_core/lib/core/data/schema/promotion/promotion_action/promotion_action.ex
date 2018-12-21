defmodule Snitch.Data.Schema.PromotionAction do
  @moduledoc """
  Models the `actions` to be activated for a `promotion`.

  The actions are after effects of `promotion` application and
  create adjustments for the payload depending on the type of action.

  An action of type `free shipping` will remove the shipping cost for
  the order whereas a discount action will provide some adjustment on the
  total order price.

  An action can be on the entire order or individual lineitem depending on
  the type of action.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.Promotion

  @type t :: %__MODULE__{}

  schema "snitch_promotion_actions" do
    field(:name, :string)
    field(:module, PromotionActionEnum)
    field(:preferences, :map)

    # associations
    belongs_to(:promotion, Promotion)

    timestamps()
  end

  @required_params ~w(name module)a
  @optional_params ~w(preferences promotion_id)a
  @create_params @required_params ++ @optional_params

  def changeset(%__MODULE__{} = action, params) do
    action
    |> cast(params, @create_params)
    |> validate_required(@required_params)
    |> common_changeset()
  end

  ############################ Private Function ##################

  defp common_changeset(changeset) do
    changeset
    |> unique_constraint(:name)
    |> foreign_key_constraint(:promotion_id)
    |> validate_preference_with_target()
  end

  defp validate_preference_with_target(%Ecto.Changeset{valid?: true} = changeset) do
    with {:ok, preferences} <- fetch_change(changeset, :preferences),
         {:ok, module} <- fetch_change(changeset, :module) do
      preference_changeset = module.changeset(struct(module), preferences)
      add_preferences_change(preference_changeset, changeset)
    else
      :error ->
        changeset

      {:error, message} ->
        add_error(changeset, :module, message)
    end
  end

  defp validate_preference_with_target(changeset), do: changeset

  defp add_preferences_change(%Ecto.Changeset{valid?: true} = pref_changeset, changeset) do
    data = pref_changeset.changes
    put_change(changeset, :preferences, data)
  end

  defp add_preferences_change(pref_changeset, changeset) do
    additional_info =
      pref_changeset
      |> traverse_errors(fn {_msg, opts} ->
        Enum.reduce(opts, %{}, fn {key, value}, acc ->
          Map.put(acc, key, value)
        end)
      end)

    add_error(changeset, :preferences, "invalid_preferences", additional_info)
  end
end
