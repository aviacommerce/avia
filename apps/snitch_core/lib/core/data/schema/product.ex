defmodule Snitch.Data.Schema.Product do
  @moduledoc """
  Models a Product.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.Product.NameSlug
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

    has_many(:variants, Variant)
  end

  @required_fields ~w(name)a
  @optional_fields ~w(description meta_description meta_keywords meta_title)a

  def changeset(model, params \\ %{}) do
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
