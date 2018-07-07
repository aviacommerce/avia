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
        Guardian.encode_and_sign(user, %{}, ttl: {1, :minute})

      _ ->
        {:error, :unauthorized}
    end
  end

  # defp email_password_auth(email, password) when is_binary(email) and is_binary(password) do
  #   with {:ok, user} <- get_by_email(email),
  #     do: verify_password(password, user)
  # end
  #
  # defp get_by_email(email) when is_binary(email) do
  #   case Repo.get_by(User, email: email) do
  #     nil ->
  #       dummy_checkpw()
  #       {:error, "Login error."}
  #     user ->
  #       {:ok, user}
  #   end
  # end
  #
  # defp verify_password(password, %User{} = user) when is_binary(password) do
  #   if checkpw(password, user.password_hash) do
  #     {:ok, user}
  #   else
  #     {:error, :invalid_password}
  #   end
  # end

  @doc """
  Updates a user.

  ## Examples

  iex> update_user(user, %{field: new_value})
  {:ok, %User{}}

  iex> update_user(user, %{field: bad_value})
  {:error, ...}

  """
  def update_user(%User{} = user, attrs) do
    raise "TODO"
  end

  @doc """
  Deletes a User.

  ## Examples

  iex> delete_user(user)
  {:ok, %User{}}

  iex> delete_user(user)
  {:error, ...}

  """
  def delete_user(%User{} = user) do
    raise "TODO"
  end

  @doc """
  Returns a datastructure for tracking user changes.

  ## Examples

  iex> change_user(user)
  %Todo{...}

  """
  def change_user(%User{} = user) do
    raise "TODO"
  end
end
