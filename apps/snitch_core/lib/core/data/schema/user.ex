defmodule Snitch.Data.Schema.User do
  @moduledoc """
  Models a User
  """
  use Snitch.Data.Schema
  alias Comeonin.Argon2

  @password_min_length 8
  @type t :: %__MODULE__{}

  schema "snitch_users" do
    # why do we need these fields?
    field(:first_name, :string)
    # why do we need these fields?
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
    timestamps(type: :utc_datetime)
  end

  @create_fields ~w(first_name last_name email password password_confirmation is_admin)a
  @update_fields ~w(sign_in_count failed_attempts)a ++ @create_fields

  @doc """
  Returns a complete changeset depending on action.

  The `action` field can be either `:create` or `:update`.

  * `:create`
    - A map with fields first_name, last_name, email, password,
      and password_confirmation is expected.
  * `:update`
    - No required fields.

  ## Note
  The changeset `action` is not set.
  """

  @spec changeset(__MODULE__.t(), map, :create | :update) :: Ecto.Changeset.t()
  def changeset(user, params, action) do
    user
    |> cast(params, @create_fields ++ @update_fields)
    |> validate_confirmation(:password)
    |> validate_length(:password, min: @password_min_length)
    |> validate_format(:email, ~r/@/)
    |> do_changeset(action)
  end

  @spec create_changeset(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp create_changeset(user_changeset) do
    user_changeset
    |> validate_required(List.delete(@create_fields, :is_admin))
    |> put_pass_hash
  end

  @spec update_changeset(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp update_changeset(%{changes: changes} = user_changeset) do
    cond do
      Map.has_key?(changes, :password) ->
        user_changeset
        |> put_pass_hash

      true ->
        user_changeset
    end
  end

  defp do_changeset(changeset, :create), do: create_changeset(changeset)
  defp do_changeset(changeset, :update), do: update_changeset(changeset)

  defp put_pass_hash(%Ecto.Changeset{valid?: true} = changeset) do
    %Ecto.Changeset{changes: %{password: password}} = changeset

    changeset
    |> change(Argon2.add_hash(password))
    |> delete_change(:password_confirmation)
  end

  defp put_pass_hash(changeset), do: changeset
end
