defmodule Snitch.Data.Schema.RatingOption do
  @moduledoc """
  Models a Rating Option.

  `rating_options` allow to create different types
  of `options` for a `rating` type.
  e.g.
  For a `rating` of type "product" there can be rating
  options as:
  [{"1", 1, 1}, {"2", 2, 2}, {"3", 3, 3}, {"4", 4, 4}, {"5", 5, 5}]
  which is basically the format [{code, value, position}]
  This allows a product to be given a rating from 1 to 5.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.Rating

  @type t :: %__MODULE__{}

  schema "snitch_rating_options" do
    field(:code, :string, null: false)
    field(:value, :integer, null: false)
    field(:position, :integer, null: false)

    belongs_to(:rating, Rating)

    timestamps()
  end

  @required_fields ~w(code value position rating_id)a
  @update_fields ~w(position code)a

  @doc """
  Returns a create changeset for rating option.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = rating_option, params) do
    rating_option
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:rating_id)
  end

  @doc """
  Returns a create changeset for rating option.
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = rating_option, params) do
    rating_option
    |> cast(params, @update_fields)
    |> validate_required(@update_fields)
  end
end
