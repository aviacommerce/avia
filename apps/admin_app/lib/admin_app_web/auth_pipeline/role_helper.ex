defmodule AdminAppWeb.RoleHelper do
  @moduledoc """
  Provides helper functions to work with roles.
  """

  @doc """
  Returns the access status based on supplied inputs.

  It checks whether the `controller` and it's `action` supplied in
  input falls under any of the supplied `permission_codes` declared
  in `role_mainfest.yaml`. In case it does the function returns
  `true` otherwise `false`.

  In case the "role" passed in the input is "admin", in that
  case access to all the controller functions is allowed and,
  the funtion returns `true`.
  """
  @spec is_accessible?(String.t(), [String.t()], String.t(), String.t()) :: boolean
  def is_accessible?("admin", _, _, _), do: true

  def is_accessible?(_role, permission_codes, controller, action) do
    {:ok, permissions} = load_role_manifest()

    permission_status_list =
      for permission_code <- permission_codes,
          permission <- permissions,
          Map.has_key?(permission, permission_code),
          Map.has_key?(permission[permission_code], controller) do
        Enum.member?(permission[permission_code][controller], action)
      end

    Enum.any?(permission_status_list, fn status -> status === true end)
  end

  defp load_role_manifest do
    File.cwd!()
    |> Path.join("/priv/role_manifest.yaml")
    |> YamlElixir.read_from_file()
  end
end
