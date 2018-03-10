defmodule Snitch.Data.Schema.User do
  @moduledoc """
  Models a User
  """
  use Snitch.Data.Schema

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
    field(:is_admin?, :boolean, default: false)

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

  @required_fields ~w(first_name last_name email is_admin?)a
  @password_fields ~w(password password_confirmation)a

  @spec registration_changeset(__MODULE__.t(), map) :: Ecto.Changeset.t()
  @doc """
  Returns a changeset to register a new user
  """
  def registration_changeset(user, params) do
    user
    |> changeset(params)
    |> validate_required(@password_fields)
    |> validate_confirmation(:password)
    |> validate_password(:password)
    |> put_pass_hash()
  end

  @spec changeset(__MODULE__.t(), map) :: Ecto.Changeset.t()
  def changeset(user, params) do
    user
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset, field) do
    validate_change(changeset, field, fn _, password ->
      case valid_password?(password) do
        :ok -> []
        {:error, msg} -> [{field, {msg, validation: :password}}]
      end
    end)
  end

  defp valid_password?(password) when byte_size(password) >= @password_min_length, do: :ok

  defp valid_password?(_) do
    {:error, "The password must be #{@password_min_length} characters long."}
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true} = changeset) do
    %Ecto.Changeset{changes: %{password: password}} = changeset

    changeset
    |> change(Comeonin.Argon2.add_hash(password))
    |> delete_change(:password_confirmation)
  end

  defp put_pass_hash(changeset), do: changeset
end
