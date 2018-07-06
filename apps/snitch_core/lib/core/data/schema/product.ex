defmodule Snitch.Data.Schema.Product do
  @moduledoc """
  Models a Product.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.Product.NameSlug
  alias Snitch.Data.Schema.Review
  alias Snitch.Data.Schema.Variant

  @type t :: %__MODULE__{}

  schema "snitch_products" do
    field(:name, :string, null: false, default: "")
    field(:description, :string)
    field(:available_on, :utc_datetime)
    field(:deleted_at, :utc_datetime)
    field(:discontinue_on, :utc_datetime)
    field(:slug, :string)
    field(:meta_description, :string)
    field(:meta_keywords, :string)
    field(:meta_title, :string)
    field(:promotionable, :boolean)
    timestamps()

    # associations
    has_many(:variants, Variant)
    many_to_many(:reviews, Review, join_through: "snitch_product_reviews")
  end

  @required_fields ~w(name)a
  @optional_fields ~w(description meta_description meta_keywords
    meta_title average_rating review_count)a

  def changeset(model, params \\ %{}) do
    common_changeset(model, params)
  end

  def update_changeset(%__MODULE__{} = product, params) do
    common_changeset(product, params)
  end

  def common_changeset(model, params) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> NameSlug.maybe_generate_slug()
    |> NameSlug.unique_constraint()
  end
end

defmodule Snitch.Data.Schema.Product.NameSlug do
  @moduledoc false

  use EctoAutoslugField.Slug, from: :name, to: :slug
end
