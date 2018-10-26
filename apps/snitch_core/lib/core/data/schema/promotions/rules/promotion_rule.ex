defmodule Snitch.Data.Schema.PromotionRule do
  @moduledoc false

  use Snitch.Data.Schema

  @type t :: %__MODULE__{}

  embedded_schema do
    field(:name, :string)
    field(:module, Ecto.Atom)
    field(:preferences, :map)
  end

  @optional_fields ~w(name module)a
  @required_fields ~w(preferences)a

  @create_fields @optional_fields ++ @required_fields

  def changeset(%__MODULE__{} = rule, params) do
    rule
    |> cast(params, @create_fields)
    |> validate_required(@required_fields)
    |> validate_preference_with_target()
  end

  def validate_preference_with_target(%Ecto.Changeset{valid?: true} = changeset) do
    with {:ok, preferences} <- fetch_change(changeset, :preferences) do
      module = get_field(changeset, :module)
      preference_changeset = module.changeset(struct(module), preferences)
      add_preferences_change(preference_changeset, changeset)
    else
      :error ->
        changeset
    end
  end

  def validate_preference_with_target(changeset), do: changeset

  defp add_preferences_change(%Ecto.Changeset{valid?: true} = pref_changeset, changeset) do
    data = Map.from_struct(pref_changeset.data)
    put_change(changeset, :preferences, data)
  end

  defp add_preferences_change(pref_changeset, changeset) do
    put_change(changeset, :preferences, pref_changeset)
  end
end
