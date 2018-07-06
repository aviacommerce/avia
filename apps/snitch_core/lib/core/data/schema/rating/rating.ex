defmodule Snitch.Data.Schema.Rating do
  @moduledoc """
  Models a Rating.

  `rating` define the different types of enities
  for which a rating can be given.

  The `code` field represents the entity
  e.g. a ratings for products has the code as "product".
  The position `field` is just a helper for the sequence in which
  the `ratings` would be shown.

  It is used to identify the `rating_options` for a
  particular `entity`.
  ## See
  `Snitch.Data.Schema.RatingOption`
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.RatingOption
  @type t :: %__MODULE__{}

  schema "snitch_ratings" do
    field(:code, :string)
    field(:position, :integer)

    has_many(:rating_options, RatingOption)
    timestamps()
  end

  @doc """
  Returns a create changeset for `rating`.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = rating, params) do
    common_changeset(rating, params)
  end

  @doc """
  Returns an update changeset for `rating`.
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = rating, params) do
    common_changeset(rating, params)
  end

  defp common_changeset(rating, params) do
    rating
    |> cast(params, [:code, :position])
    |> validate_required(:code)
    |> unique_constraint(:code)
  end
end
