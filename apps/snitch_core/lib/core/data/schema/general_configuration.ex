defmodule Snitch.Data.Schema.GeneralConfiguration do
  @moduledoc """
  Models the General Configuration for Snitch
  """
  use Snitch.Data.Schema

  alias Snitch.Data.Schema.{Image, StoreLogo}

  # TODO : The approach to handle general settings needs
  #       to be optimized!

  @type t :: %__MODULE__{}

  schema "snitch_general_configurations" do
    field(:name, :string)
    field(:sender_mail, :string)
    field(:seo_title, :string)
    field(:frontend_url, :string)
    field(:backend_url, :string)
    field(:currency, :string)
    field(:tenant, :string, virtual: true)

    has_one(:store_image, StoreLogo, on_replace: :delete)
    has_one(:image, through: [:store_image, :image])

    timestamps()
  end

  @required_fields ~w(name sender_mail currency)a
  @optional_fields ~w(seo_title frontend_url backend_url)a
  @fields @required_fields ++ @optional_fields

  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = general_configuration, params) do
    general_configuration
    |> Repo.preload([:image])
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:store_image, with: &StoreLogo.changeset/2)
  end

  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = general_configuration, params) do
    general_configuration
    |> Repo.preload([:store_image])
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:store_image, with: &StoreLogo.changeset/2)
  end
end
