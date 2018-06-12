defmodule Snitch.Seed.Users do
  @moduledoc false

  alias Comeonin.Argon2
  alias Ecto.DateTime
  alias Snitch.Data.Model.{Country, State}
  alias Snitch.Data.Schema.{Address, User}
  alias Snitch.Repo

  require Logger

  @user_passwd Argon2.hashpwsalt("avenger")
  @admin_passwd Argon2.hashpwsalt("wizard")

  @address %Address{
    first_name: "Tony",
    last_name: "Stark",
    address_line_1: "10-8-80 Malibu Point",
    zip_code: "90265",
    city: "Malibu",
    phone: "1234567890"
  }

  def seed_users! do
    users = [
      user("Harry", "Potter", "admin@snitch.com", @admin_passwd, true),
      user("Tony", "Stark", "tony@snitch.com", @user_passwd),
      user("Steven", "Rogers", "steven@snitch.com", @user_passwd)
    ]

    Repo.insert_all(User, users, on_conflict: :nothing, conflict_target: [:email])
    Logger.info("Inserted #{length(users)} users.")
  end

  def user(first_name, last_name, email, pwd_hash, admin \\ false) do
    %{
      first_name: first_name,
      last_name: last_name,
      email: email,
      password_hash: pwd_hash,
      is_admin: admin,
      inserted_at: DateTime.utc(),
      updated_at: DateTime.utc()
    }
  end

  def seed_address! do
    california = State.get(%{code: "US-CA"})
    us = Country.get(%{iso: "US"})
    Repo.insert!(%{@address | state_id: california.id, country_id: us.id})
  end
end
