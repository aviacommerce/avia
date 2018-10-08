defmodule Snitch.Domain.Account do
  @moduledoc """
  Exposes domain functions for authentication.
  """
  alias Snitch.Data.Model.User
  alias Snitch.Data.Schema.User, as: UserSchema
  alias Comeonin.Argon2
  alias Snitch.Repo

  @doc """
  Registers a `user` with supplied `params`.

  Takes a `params` map as input.
  """
  @spec register(map) :: {:ok, UserSchema.t()} | {:error}
  def register(params) do
    User.create(params)
  end

  @spec authenticate(String.t(), String.t()) :: {:ok, UserSchema.t()} | {:error, :not_found}
  def authenticate(email, password) do
    verify_email(User.get(%{email: email}) |> Repo.preload(:role), password)
  end

  defp verify_email(nil, _) do
    # To make user enumeration difficult.
    Argon2.dummy_checkpw()
    {:error, :not_found}
  end

  defp verify_email(user, password) do
    verify_password(user, Argon2.checkpw(password, user.password_hash))
  end

  defp verify_password(user, true = _password_matches), do: {:ok, user}
  defp verify_password(_user, _), do: {:error, :not_found}
end
