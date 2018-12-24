defmodule Snitch.Data.Schema.Adjustment do
  @moduledoc """
  Models a generic `adjustment` to keep a track of adjustments
  made against any entity.

  Adjustments can be made against entities such as an `order` or
  `lineitem` due to various reasons such as adding a promotion, or adding
  taxes etc.
  The adjustments table has a polymorphic relationship with the actions leading
  to it.
  """

  use Snitch.Data.Schema
  @type t :: %__MODULE__{}

  schema "snitch_adjustments" do
    field(:adjustable_type, AdjustableEnum)
    field(:adjustable_id, :integer)
    field(:amount, :decimal)
    field(:label, :string)
    field(:eligible, :boolean, default: false)
    field(:included, :boolean, default: false)

    timestamps()
  end

  @required_params ~w(adjustable_id adjustable_type amount)a
  @optional_params ~w(label eligible included)a

  @all_params @required_params ++ @optional_params

  def create_changeset(%__MODULE__{} = adjustment, params) do
    adjustment
    |> cast(params, @all_params)
    |> validate_required(@required_params)
  end

  def update_changeset(%__MODULE__{} = adjustment, params) do
    adjustment
    |> cast(params, @optional_params)
  end
end
