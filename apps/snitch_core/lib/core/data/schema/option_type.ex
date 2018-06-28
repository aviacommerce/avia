defmodule Snitch.Data.Schema.OptionType do
  @moduledoc """
  Models an OptionType
  """
  use Snitch.Data.Schema

  alias Snitch.Data.Schema.TemplateOptionValue

  @type t :: %__MODULE__{}

  schema "snitch_option_types" do
    field(:name, :string)
    field(:display_name, :string)

    has_many(:template_option_values, TemplateOptionValue)
    timestamps()
  end

  @create_params ~w(name display_name)a

  @doc """
  Returns a changeset to create new OptionType
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(model, params) do
    common_changeset(model, params)
  end

  @doc """
  Returns a changeset to update a OptionType
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(model, params) do
    common_changeset(model, params)
  end

  defp common_changeset(model, params) do
    model
    |> cast(params, @create_params)
    |> validate_required(@create_params)
  end
end
