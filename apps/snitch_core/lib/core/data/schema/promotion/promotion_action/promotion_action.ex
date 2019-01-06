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

  @doc """
  Performs the action for the promotion.

  The function should be implemented by individual action types.

  ### Note
  The function usually has side effects such as writing to the database.

  Returns a boolean depending on whether the action was applied or not.
  """
  @callback perform?(
              order :: Order.t(),
              promtoion :: Promotion.t(),
              action :: PromotionAction.t()
            ) :: boolean()

  @doc """
  Returns the name of the action.
  """
  @callback action_name() :: String.t()

  schema "snitch_promotion_actions" do
    field(:name, :string)
    field(:module, PromotionActionEnum)
    field(:preferences, :map)

    # associations
    belongs_to(:promotion, Promotion)

    timestamps()
  end

  @required_params ~w(name module preferences)a
  @optional_params ~w(promotion_id)a
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
    |> validate_embedded_preferences(:module, :preferences)
  end

  defp validate_embedded_preferences(%Ecto.Changeset{valid?: true} = changeset, module_key, key) do
    with {:ok, preferences} <- fetch_change(changeset, key),
         {:ok, module_key} <- fetch_change(changeset, module_key) do
      preference_changeset = module_key.changeset(struct(module_key), preferences)
      add_preferences_change(preference_changeset, changeset, key)
    else
      :error ->
        changeset

      {:error, message} ->
        add_error(changeset, module_key, message)
    end
  end

  defp validate_embedded_preferences(changeset, _module_key, _key), do: changeset

  defp add_preferences_change(%Ecto.Changeset{valid?: true} = embed_changeset, changeset, key) do
    data = embed_changeset.changes
    put_change(changeset, key, data)
  end

  defp add_preferences_change(embed_changeset, changeset, key) do
    additional_info =
      embed_changeset
      |> traverse_errors(fn {_msg, opts} ->
        Enum.reduce(opts, %{}, fn {key, value}, acc ->
          Map.put(acc, key, value)
        end)
      end)

    add_error(changeset, key, "invalid_preferences", additional_info)
  end
end
