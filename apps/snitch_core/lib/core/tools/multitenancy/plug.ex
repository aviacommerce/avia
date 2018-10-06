defmodule Snitch.Core.Tools.MultiTenancy.Plug do
  @moduledoc """
  Custom plug to parse subdomain and set options in MultiTenancy.Repo
  Plug will send 404 error if url scheme contains subdomain and the tenant is not present in database.
  """

  import Plug.Conn
  alias Snitch.Core.Tools.MultiTenancy.Repo

  def init(options), do: options

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%Plug.Conn{host: host} = conn, opts) do
    root_host = Keyword.get(opts, :endpoint).config(:url)[:host]

    if not root_domain?(host, root_host) do
      host
      |> tenant_exists?()
      |> set_repo(host)
      |> handle_conn(conn)
    else
      conn
    end
  end

  # Private

  @spec root_domain?(String.t(), boolean()) :: boolean()
  defp root_domain?(host, root_host) do
    host in [root_host, "localhost", "0.0.0.0", "127.0.0.1"]
  end

  @spec tenant_exists?(String.t()) :: boolean()
  defp tenant_exists?(host) do
    host
    |> extract_subdomain()
    |> Triplex.exists?()
  end

  @spec extract_subdomain(String.t()) :: String.t()
  defp extract_subdomain(host) do
    String.split(host, ".")
    |> List.first()
  end

  @spec set_repo(boolean(), String.t()) :: boolean()
  defp set_repo(exists, host) do
    if exists,
      do:
        host
        |> extract_subdomain()
        |> Repo.set_tenant()

    exists
  end

  @spec handle_conn(boolean(), Plug.Conn.t()) :: Plug.Conn.t()
  defp handle_conn(exists, %Plug.Conn{host: host} = conn) do
    reserved_tenant =
      host
      |> extract_subdomain()
      |> Triplex.reserved_tenant?()

    if !reserved_tenant and !exists do
      conn
      |> put_status(:not_found)
    else
      conn
    end
  end
end
