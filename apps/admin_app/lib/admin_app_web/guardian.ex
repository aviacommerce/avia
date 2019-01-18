defmodule AdminAppWeb.Guardian do
  @moduledoc false

  use Guardian, otp_app: :admin_app
  alias Snitch.Data.Model.User
  alias Snitch.Core.Tools.MultiTenancy.Repo

  def subject_for_token(nil, _) do
    {:error, :resource_not_found}
  end

  def subject_for_token(resource, _claims) do
    sub = to_string(resource.id)
    {:ok, sub}
  end

  def resource_from_claims(nil) do
    {:error, :no_claims_found}
  end

  # TODO : The operation to load resource on every call is heavy needs
  #       to be optimized!
  def resource_from_claims(claims) do
    user_id = claims["sub"]

    current_user =
      user_id
      |> String.to_integer()
      |> User.get()

    case current_user do
      {:error, _} ->
        {:error, "user not found"}

      {:ok, user} ->
        user = user |> Repo.preload(role: [:permissions])
        {:ok, user}
    end
  end
end
