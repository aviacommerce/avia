defmodule Snitch.Data.Schema.LineItem do
  @moduledoc """
  Models a LineItem.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{Variant, Order}

  @type t :: %__MODULE__{}

  schema "snitch_line_items" do
    field(:quantity, :integer)
    field(:unit_price, Money.Ecto.Composite.Type)
    field(:total, Money.Ecto.Composite.Type)

    belongs_to(:variant, Variant)
    belongs_to(:order, Order)
    timestamps()
  end

  @required_fields ~w(quantity variant_id)a
  @optional_fields ~w(unit_price total)a

  @doc """
  Returns a `LineItem` changeset without `:total`.

  Do not persist this to DB since price fields and order are not set! To set
  prices see `update_totals/1` and `create_changeset/2`.
  """
  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = line_item, params) do
    line_item
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_number(:quantity, greater_than: 0)
    |> foreign_key_constraint(:variant_id)
    |> foreign_key_constraint(:order_id)
  end

  @doc """
  Returns a `LineItem` changeset that can be used for `insert`/`update`.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = line_item, params) do
    line_item
    |> changeset(params)
    |> validate_required(@optional_fields)
  end

  @doc """
  Returns a JSON encodable `map`.

  Associations that are not loaded are rendered as `nil`.
  """
  @spec to_map(__MODULE__.t()) :: map
  def to_map(%__MODULE__{} = line_item) do
    line_item
    |> Map.from_struct()
    |> Map.delete(:__meta__)
    |> Map.delete(:order)
    |> Map.update(:variant, nil, &Variant.to_map/1)
  end

  @spec to_map([__MODULE__.t()]) :: [map]
  def to_map(line_items) when is_list(line_items) do
    Enum.map(line_items, &to_map/1)
  end

  def to_map(_), do: nil
end

defimpl Jason.Encoder, for: Snitch.Data.Schema.LineItem do
  def encode(line_item, opts) do
    Jason.Encode.map(@for.to_map(line_item), opts)
  end
end
