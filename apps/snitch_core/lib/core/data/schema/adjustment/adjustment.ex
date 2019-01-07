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

  @typedoc """
  Represents adjustments.

  ### Fields
  - `adjustable_type`: The type of adjustable for which adjustment is created
    it can be an `order` or a `line_item`.
  - `adjustable_id`: The id of the adjustable for which the adjustment was
    created.
  - `amount`: The amount for the adjustment it can be positive or negative
    depending on whether the amount has to be added or substracted from the
    adjustable total. e.g. it is negative in case of promotions and positive
    in case of taxes.
  - `eligible`: This is used to check if the created adjustment should be
    considered while calculating totals for the adjustable. Adjustment which have
    `eligible` as true are only considered during the adjustable total
    calculations. This field is especially important while handling promotions.
    A promotion is considered applied if adjustments created due to it are
    eligible.
  - `included`: This is used to assert whether, amount adjusted is already present
    in the adjustable total. In case it is false the amount should considered
    during total computation.
  """
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
