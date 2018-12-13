defmodule Snitch.Demo.User do
  alias NimbleCSV.RFC4180, as: CSV
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Schema.{User, Role}
  alias Comeonin.Argon2
  alias Ecto.DateTime

  @base_path Application.app_dir(:snitch_core, "priv/repo/demo/demo_data")

  def create_users do
    Repo.delete_all(User)
    user_path = Path.join(@base_path, "users.csv")

    user_path
    |> File.read!()
    |> CSV.parse_string()
    |> Enum.filter(fn x -> x != "" end)
    |> Enum.each(fn [first_name, last_name, email, pwd, admin, role] ->
      role = Repo.get_by!(Role, name: role)
      create_user!(first_name, last_name, email, pwd, admin, role.id)
    end)
  end

  defp create_user!(first_name, last_name, email, pwd, admin \\ false, role_id) do
    params = %{
      first_name: first_name,
      last_name: last_name,
      email: email,
      password: pwd,
      password_confirmation: pwd,
      is_admin: admin,
      role_id: role_id,
      inserted_at: DateTime.utc(),
      updated_at: DateTime.utc()
    }

    %User{} |> User.create_changeset(params) |> Repo.insert!()
  end
end
