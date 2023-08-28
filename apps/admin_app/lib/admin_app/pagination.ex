defmodule Snitch.Pagination do
  @moduledoc """
  Module with functions to query the database according to the 
  requested data per page.
  """
  import Ecto.Query
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Rummage.Ecto.Hook.Paginate

  def page(query, page, per_page \\ 10)

  def page(query, page, per_page) when is_nil(page) do
    page(query, 1, per_page)
  end

  def page(query, page, per_page) when is_binary(page) do
    page = String.to_integer(page)
    page(query, page, per_page)
  end

  def page(query, page, per_page) do
    count = per_page + 1

    %{max_page: max_page, total_count: total_count} = Paginate.format_params(query, %{
      per_page: per_page,
      page: page
    }, [repo: Repo])
    
    result =
      query
      |> limit(^count)
      |> offset(^(per_page * (page - 1)))
      |> Repo.all()

    has_next = page < max_page
    has_prev = page > 1
    
    page = %{
      has_next: has_next,
      has_prev: has_prev,
      prev_page: page - 1,
      next_page: page + 1,
      page: page,
      first: (page - 1) * per_page + 1,
      last: Enum.min([page * per_page, total_count]),
      count: total_count,
      list: Enum.slice(result, 0, per_page),
      max_page: max_page,
      per_page: per_page
    }
  end
end
