defmodule Core.Snitch.LineItem do
  @moduledoc """
  Models a LineItem
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  @type t :: %__MODULE__{}

  schema "snitch_line_items" do
    field(:quantity, :integer)
    field(:unit_price, Money.Ecto.Composite.Type)
    field(:total, Money.Ecto.Composite.Type, virtual: true)

    belongs_to(:variant, Core.Snitch.Variant)
    belongs_to(:order, Core.Snitch.Order)
    timestamps()
  end

  @required_fields ~w(quantity variant_id)a
  @optional_fields ~w()a

  @spec create_changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def create_changeset(line_item, params) do
    line_item
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_number(:quantity, greater_than: 0)
    |> foreign_key_constraint(:variant_id)
    |> foreign_key_constraint(:order_id)
  end

  @spec build(non_neg_integer(), non_neg_integer()) :: Ecto.Changeset.t()
  def build(variant_id, quantity) do
    %__MODULE__{}
    |> create_changeset(%{variant_id: variant_id, quantity: quantity})
  end
end
