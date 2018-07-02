defmodule Snitch.Data.Schema.Property do
  @moduledoc """
  Models product property
  """

  use Snitch.Data.Schema

  @type t :: %__MODULE__{}

  schema "snitch_properties" do
    field(:name, :string)
    field(:display_name, :string)
    timestamps()
  end

  @create_params ~w(name display_name)a

  @doc """
  Returns a changeset to create new Property
  """
  def create_changeset(model, params) do
    common_changeset(model, params)
  end

  @doc """
  Returns a changeset to update a Property
  """
  def update_changeset(model, params) do
    common_changeset(model, params)
  end

  defp common_changeset(model, params) do
    model
    |> cast(params, @create_params)
    |> validate_required(@create_params)
    |> unique_constraint(:name)
  end
end
