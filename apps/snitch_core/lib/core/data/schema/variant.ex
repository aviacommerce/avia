defmodule Snitch.Data.Schema.Variant do
  @moduledoc """
  Models a Product variant.
  """

  use Snitch.Data.Schema

  import Ecto.Query

  alias Snitch.Data.Schema.StockItem
  alias Snitch.Repo
  alias Money.Ecto.Composite.Type, as: MoneyType

  @type t :: %__MODULE__{}

  schema "snitch_variants" do
    field(:sku, :string, default: "")
    field(:weight, :decimal, default: Decimal.new(0))
    field(:height, :decimal)
    field(:width, :decimal)
    field(:depth, :decimal)
    field(:is_master, :boolean, default: false)
    field(:cost_price, MoneyType)
    field(:position, :integer)
    field(:track_inventory, :boolean, default: true)
    field(:discontinue_on, :naive_datetime)

    has_many(:stock_items, StockItem)

    timestamps()
  end

  @permitted_fields ~w(sku weight height width depth is_master)a ++
                      ~w(cost_price position track_inventory discontinue_on)a

  def changeset(%__MODULE__{} = variant, attrs) do
    variant
    |> cast(attrs, @permitted_fields)
    |> unique_constraint(:sku)

    # Ensures a new variant takes the product master price when price is not supplied
    # Ensure variants? are not soft deleted
  end

  @doc """
  Returns the selling prices of a list of `Variant`s.

  ## Note
  **The function currently returns the cost price (as there's no price table)**.
  """
  @spec get_selling_prices([non_neg_integer]) :: %{non_neg_integer: Money.t()}
  def get_selling_prices(variant_ids) do
    # TODO: change the table to snitch_prices when it becomes available
    query =
      from(v in "snitch_variants", select: [v.id, v.cost_price], where: v.id in ^variant_ids)

    query
    |> Repo.all()
    |> Enum.reduce(%{}, fn [v_id, cp], acc ->
      {:ok, cost} = MoneyType.load(cp)
      Map.put(acc, v_id, cost)
    end)
  end
end
