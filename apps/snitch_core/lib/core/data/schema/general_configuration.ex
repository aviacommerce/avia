defmodule Snitch.Data.Schema.GeneralConfiguration do
  @moduledoc """
  Models the General Configuration for Snitch
  """
  use Snitch.Data.Schema

  # TODO : The approach to handle general settings needs
  #       to be optimized!

  @type t :: %__MODULE__{}

  schema "snitch_general_configurations" do
    field(:name, :string)
    field(:meta_description, :string)
    field(:meta_keywords, :string)
    field(:seo_title, :string)
    field(:sender_mail, :string)
    field(:sendgrid_api_key, :string)
    field(:currency, :string)

    timestamps()
  end

  @required_fields ~w(name meta_description meta_keywords seo_title sender_mail sendgrid_api_key currency)a

  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = general_configuration, params) do
    general_configuration
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end

  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = general_configuration, params) do
    general_configuration
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
