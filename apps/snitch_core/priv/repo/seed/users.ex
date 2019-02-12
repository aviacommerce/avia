defmodule Snitch.Seed.Users do
  @moduledoc false

  alias Comeonin.Argon2
  alias Ecto.DateTime
  alias Snitch.Data.Model.{Country, State}
  alias Snitch.Data.Schema.{Address, User, Role}
  alias Snitch.Core.Tools.MultiTenancy.Repo

  require Logger

  @user_passwd Argon2.hashpwsalt("avenger")
  @admin_passwd Argon2.hashpwsalt("wizard123")

  def seed_users! do
    admin_role = Repo.get_by!(Role, name: "admin")

    users = [
      user("Harry", "Potter", "admin@aviacommerce.com", @admin_passwd, true, admin_role.id)
    ]

    Repo.insert_all(User, users, on_conflict: :nothing, conflict_target: [:email, :deleted_at])
    Logger.info("Inserted #{length(users)} users.")
  end

  def user(first_name, last_name, email, pwd_hash, admin \\ false, role_id) do
    %{
      first_name: first_name,
      last_name: last_name,
      email: email,
      password_hash: pwd_hash,
      is_admin: admin,
      role_id: role_id,
      inserted_at: DateTime.utc(),
      updated_at: DateTime.utc()
    }
  end

  defp get_id({:ok, struct}) do
    struct.id
  end

  def seed_address! do
    Repo.delete_all(Address)

    states = %{
      state1: State.get(%{code: "US-CA"}) |> get_id,
      state2: State.get(%{code: "IN-MH"}) |> get_id,
      state3: State.get(%{code: "IN-BR"}) |> get_id
    }

    countries = %{
      country1: Country.get(%{iso: "US"}) |> get_id,
      country2: Country.get(%{iso: "IN"}) |> get_id,
      country3: Country.get(%{iso: "IN"}) |> get_id
    }

    Enum.map(
      [
        %Address{
          first_name: "Tony",
          last_name: "Stark",
          address_line_1: "10-8-80 Malibu Point",
          zip_code: "90265",
          city: "Malibu",
          phone: "1234567890",
          state_id: states.state1,
          country_id: countries.country1
        },
        %Address{
          first_name: "noname",
          last_name: "noname",
          address_line_1: "somewhere",
          address_line_2: "street",
          zip_code: "00000",
          city: "Pune",
          phone: "1234567890",
          state_id: states.state2,
          country_id: countries.country2
        },
        %Address{
          first_name: "noname",
          last_name: "noname",
          address_line_1: "nowhere",
          address_line_2: "street",
          zip_code: "11111",
          city: "Patna",
          phone: "1234567890",
          state_id: states.state3,
          country_id: countries.country3
        }
      ],
      &Repo.insert!/1
    )
  end
end
