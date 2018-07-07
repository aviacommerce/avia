defmodule SnitchApi.Guardian do
  use Guardian, otp_app: :snitch_api

  def subject_for_token(user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(%{"sub" => id}) do
    case SnitchApi.Accounts.get_user!(id) do
      nil -> {:error, :resource_not_found}
      resource -> {:ok, resource}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
