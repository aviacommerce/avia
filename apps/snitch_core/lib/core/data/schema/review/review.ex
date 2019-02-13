defmodule Snitch.Data.Schema.Review do
  @moduledoc """
  Models Reviews.

  Reviews represent customer feedback for any entity in the
  e-commerce. Reviews can be given for any service so it
  has to be generic.

  `reviews` has_one `rating_option_vote`.
  ## See
  `Snitch.Data.Schema.RatingOptionVote`
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.RatingOptionVote
  alias Snitch.Data.Schema.User

  @type t :: %__MODULE__{}

  schema "snitch_reviews" do
    field(:title, :string)
    field(:description, :string)
    field(:approved, :boolean, default: false)
    field(:locale, :string)
    field(:name, :string)

    # associations
    belongs_to(:user, User)
    has_one(:rating_option_vote, RatingOptionVote, on_replace: :delete)

    timestamps()
  end

  @required_params ~w(description user_id name)a
  @optional_params ~w(title locale approved)a

  @create_params @required_params ++ @optional_params
  @update_params ~w(description)a ++ @optional_params

  @doc """
  Returns a product review changeset.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = review, params) do
    review
    |> cast(params, @create_params)
    |> common_changeset()
  end

  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = review, params) do
    review
    |> cast(params, @update_params)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> validate_required(@required_params)
    |> foreign_key_constraint(:user_id)
    |> cast_assoc(
      :rating_option_vote,
      required: true,
      with: &RatingOptionVote.create_changeset/2
    )
  end
end
