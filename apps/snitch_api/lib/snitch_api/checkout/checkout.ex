defmodule SnitchApi.Checkout do
  @moduledoc """
  The Checkout context.
  """

  import Ecto.Query, only: [from: 2, order_by: 2]

  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias SnitchApi.API
  alias Snitch.Data.Schema.Address

  # TODO Remove connection coupling
  @doc """
  Returns the list of addresses.

  ## Examples

      iex> list_addresses()
      [%Address{}, ...]

  """
  def list_addresses(conn, _params) do
    current_user = conn.assigns[:current_user]
    query = from(a in Address, where: a.user_id == ^current_user.id)
    Repo.all(query)
  end

  @doc """
  Gets a single address.

  Raises if the Address does not exist.

  ## Examples

      iex> get_address!(123)
      %Address{}

  """
  def get_address!(id), do: Repo.get(Address, id)

  @doc """
  Creates a address.

  ## Examples

      iex> create_address(%{field: value})
      {:ok, %Address{}}

      iex> create_address(%{field: bad_value})
      {:error, ...}

  """
  def create_address(attrs \\ %{}) do
    %Address{}
    |> Address.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a address.

  ## Examples

      iex> update_address(address, %{field: new_value})
      {:ok, %Address{}}

      iex> update_address(address, %{field: bad_value})
      {:error, ...}

  """
  def update_address(%Address{} = address, attrs) do
    address
    |> Address.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Address.

  ## Examples

      iex> delete_address(address)
      {:ok, %Address{}}

      iex> delete_address(address)
      {:error, ...}

  """
  def delete_address(%Address{} = address) do
    Repo.delete(address)
  end
end
