defmodule Snitch.Data.Schema.RatingOptionVote do
  @moduledoc """
  Models Rating option vote.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.RatingOption
  alias Snitch.Data.Schema.Review

  @type t :: %__MODULE__{}

  schema "snitch_rating_option_votes" do
    ## TODO check the viablility of these fields
    # field(:value, :string)
    # field(:percent, :string)

    belongs_to(:rating_option, RatingOption)
    belongs_to(:review, Review)

    timestamps()
  end

  @doc """
  Returns a create changeset for rating option vote.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = rating_option_vote, params) do
    rating_option_vote
    |> cast(params, [])
    |> put_assoc(:rating_option, params[:rating_option])
  end

  @doc """
  Returns an update changeset for rating option vote.
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = rating_option_vote, params) do
    rating_option_vote
    |> cast(params, [])
    |> put_assoc(:rating_option, params)
  end
end
