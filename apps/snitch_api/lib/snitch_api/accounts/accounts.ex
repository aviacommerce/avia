defmodule SnitchApi.Accounts do
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  alias Snitch.Data.Model.User, as: UserModel
  alias Snitch.Data.Schema.User
  alias Snitch.Domain.Account
  alias SnitchApi.Guardian
  alias Snitch.Repo

  @moduledoc """
  The Accounts context.
  """

  @doc """
  Returns the list of users.

  ## Examples

  iex> list_users()
  [%User{}, ...]

  """
  def list_users do
    raise "TODO"
  end

  @doc """
  Gets a single user.

  Raises if the User does not exist.

  ## Examples

  iex> get_user!(123)
  %User{}

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

  iex> create_user(%{field: value})
  {:ok, %User{}}

  iex> create_user(%{field: bad_value})
  {:error, ...}

  """
  def create_user(attrs \\ %{}) do
    attrs
    |> Map.put("role_id", 1)
    |> Account.register()
  end

  def token_sign_in(email, password) do
    case Account.authenticate(email, password) do
      {:ok, user} ->
        Guardian.encode_and_sign(user, %{}, ttl: {10, :minute})

      _ ->
        {:error, :unauthorized}
    end
  end

  def resource_from_token(token) do
    case Guardian.resource_from_token(token) do
      {:ok, resource, _claims} ->
        resource

      {:error, :token_expired} ->
        :expired
    end
  end

  def refresh_token(token) do
    {:ok, _old_stuff, {new_token, new_claims}} = Guardian.refresh(token)
    {new_token, new_claims}
  end

  def verify_token(token) do
    Guardian.decode_and_verify(token)
  end
end
