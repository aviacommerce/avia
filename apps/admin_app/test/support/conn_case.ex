defmodule AdminAppWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate
  alias Ecto.Adapters.SQL.Sandbox
  alias Phoenix.ConnTest

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import AdminAppWeb.Router.Helpers
      # The default endpoint for testing
      @endpoint AdminAppWeb.Endpoint

      @default_opts [
        store: :cookie,
        key: "secretkey",
        encryption_salt: "encrypted cookie salt",
        signing_salt: "signing salt"
      ]
      @signing_opts Plug.Session.init(Keyword.put(@default_opts, :encrypt, false))

      def signin_guardian(conn, user) do
        conn =
          conn
          |> Plug.Session.call(@signing_opts)
          |> Plug.Conn.fetch_session()
          |> AdminAppWeb.Guardian.Plug.sign_in(user)
          |> Guardian.Plug.VerifySession.call([])
      end
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Snitch.Repo)

    unless tags[:async] do
      Sandbox.mode(Snitch.Repo, {:shared, self()})
    end

    :ok
  end

  setup _tags do
    {:ok, conn: ConnTest.build_conn()}
  end
end
