defmodule Snitch.Data.Schema.User do
  @moduledoc """
  Models a User
  """
  use Snitch.Data.Schema
  alias Comeonin.Argon2
  alias Snitch.Data.Schema.Role

  @password_min_length 8
  @type t :: %__MODULE__{}

  schema "snitch_users" do
    # associations
    belongs_to(:role, Role)

    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)
    field(:password_hash, :string)
    field(:is_admin, :boolean, default: false)

    field(:sign_in_count, :integer, default: 0)
    field(:failed_attempts, :integer, default: 0)
    # field :snitch_api_key,         :string
    # field :remember_token,         :string

    # field :persistence_token,      :string
    # field :reset_password_token,   :string
    # field :perishable_token,       :string
    # field :authentication_token,   :string
    # field :unlock_token,           :string
    # field :confirmation_token,     :string

    # field :last_request_at,        :string
    # field :current_sign_in_at,     :string
    # field :last_sign_in_at,        :string

    # field :current_sign_in_ip,     :string
    # field :last_sign_in_ip,        :string

    # field :login,                  :string

    # field :locked_at,              :string

    # field :reset_password_sent_at, :naive_datetime
    # field :remember_created_at,    :naive_datetime
    # field :deleted_at,             :naive_datetime
    # field :confirmed_at,           :naive_datetime
    # field :confirmation_sent_at,   :naive_datetime
    timestamps()
  end

  @required_fields ~w(first_name last_name email password password_confirmation role_id)a
  @create_fields [:is_admin | @required_fields]
  @update_fields ~w(sign_in_count failed_attempts is_admin)a ++ @create_fields

  @doc """
  Returns a `User` changeset to create a new `user`.

  `params` must contain `:first_name`, `:last_name`, `:email`, `:password`, and
  `:password_confirmation`.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(user, params) do
    user
    |> cast(params, @create_fields)
    |> validate_required(@required_fields)
    |> common_changeset()
  end

  @doc """
  Returns a `User` changeset to create to update `user`.
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(user, params) do
    user
    |> cast(params, @update_fields)
    |> common_changeset()
  end

  @spec common_changeset(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp common_changeset(user_changeset) do
    user_changeset
    |> foreign_key_constraint(:role_id)
    |> validate_confirmation(:password)
    |> validate_length(:password, min: @password_min_length)
    |> validate_format(:email, ~r/@/)
    |> put_pass_hash()
  end

  @spec put_pass_hash(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp put_pass_hash(%Ecto.Changeset{valid?: true} = changeset) do
    case fetch_change(changeset, :password) do
      {:ok, password} ->
        changeset
        |> change(Argon2.add_hash(password))
        |> delete_change(:password_confirmation)

      :error ->
        changeset
    end
  end

  defp put_pass_hash(changeset), do: changeset
end
