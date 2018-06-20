defmodule AdminAppWeb.Guardian do
  @moduledoc false

  use Guardian, otp_app: :admin_app
  alias Snitch.Data.Model.User

  def subject_for_token(resource, _claims) do
    sub = to_string(resource.id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(claims) do
    user_id = claims["sub"]
    current_user = User.get(String.to_integer(user_id))
    {:ok, current_user}
  end

  def resource_from_claims(_clais) do
    {:error, :some_error_occurred}
  end
end
