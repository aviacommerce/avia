defmodule Snitch.Data.Schema.GeneralConfiguration do
  @moduledoc """
  Models the General Configuration for Snitch
  """
  use Snitch.Data.Schema

  alias Snitch.Data.Schema.StoreLogo

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
    field(:hosted_payment_url, :string)

    timestamps()
  end

  @required_fields ~w(name sender_mail seo_title frontend_url backend_url currency hosted_payment_url)a

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
