defmodule Snitch.Data.Schema.ReturnAuthorization do
  @moduledoc """
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{ReturnAuthorizationReason, Order}

  @type t :: %__MODULE__{}

  schema "snitch_return_authorizations" do
    field(:number, :string)
    field(:state, :string)
    field(:memo, :string)

    belongs_to :order, Order
    belongs_to :return_authorization_reason, ReturnAuthorizationReason

    timestamps()
  end

  @required_fields ~w(number state return_authorization_reason_id order_id)a
  @cast_fields [:memo | @required_fields]

  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = model, params), do: changeset(model, params)

  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = model, params), do: changeset(model, params)

  defp changeset(model, params) do
    model
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
    |> validate_length(:memo, min: 10, allow_blank: true)
  end
end
