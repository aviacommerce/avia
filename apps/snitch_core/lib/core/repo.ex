defmodule Snitch.Repo do
  use Ecto.Repo, otp_app: :snitch_core, adapter: Ecto.Adapters.Postgres
end
