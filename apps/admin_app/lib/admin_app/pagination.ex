defmodule Snitch.Pagination do
  import Ecto.Query
  alias Snitch.Core.Tools.MultiTenancy.Repo
  #
  # ## Example
  #
  #    Snippets.Snippet
  #    |> order_by(desc: :inserted_at)
  #    |> Pagination.page(0, per_page: 10)
  #
  def page(query, page, per_page: per_page) when is_nil(page) do
    page(query, 0, per_page: per_page)
  end

  def page(query, page, per_page: per_page) when is_binary(page) do
    page = String.to_integer(page)
    page(query, page, per_page: per_page)
  end

  def page(query, page, per_page: per_page) do
    count = per_page + 1

    result =
      query
      |> limit(^count)
      |> offset(^(page * per_page))
      |> Repo.all()

    has_next = length(result) == count
    has_prev = page > 0
    total_count = Repo.aggregate(from(p in query), :count, :id)

    page = %{
      has_next: has_next,
      has_prev: has_prev,
      prev_page: page - 1,
      next_page: page + 1,
      page: page,
      first: page * per_page + 1,
      last: Enum.min([page + 1 * per_page, total_count]),
      count: total_count,
      list: Enum.slice(result, 0, count - 1)
    }
  end
end
