defmodule Snitch.Core.Tools.MultiTenancy.Helper do
  alias Ecto.Multi
  alias Snitch.Repo
  alias Snitch.Core.Tools.MultiTenancy

  defmacro defrepo(cmd, args, :append) do
    margs = Enum.map(args, fn x -> {x, [], __MODULE__} end)

    quote do
      def unquote(cmd)(unquote_splicing(margs)) do
        apply(Repo, unquote(cmd), [unquote_splicing(margs), MultiTenancy.Repo.get_opts()])
      end
    end
  end

  defmacro defrepo(cmd, args, :pass) do
    margs = Enum.map(args, fn x -> {x, [], __MODULE__} end)

    quote do
      def unquote(cmd)(unquote_splicing(margs)) do
        apply(Repo, unquote(cmd), [unquote_splicing(margs)])
      end
    end
  end

  defmacro defmulti(cmd, args, :append) do
    margs = Enum.map(args, fn x -> {x, [], __MODULE__} end)

    quote do
      def unquote(cmd)(unquote_splicing(margs)) do
        apply(Multi, unquote(cmd), [unquote_splicing(margs), MultiTenancy.Repo.get_opts()])
      end
    end
  end
end
