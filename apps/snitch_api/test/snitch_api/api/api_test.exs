defmodule SnitchApi.APITest do
  use SnitchApiWeb.ConnCase, async: true

  # alias SnitchApi.API, as: Context #uncomment when needed

  describe "products" do
    alias Snitch.Product

    @valid_attrs %{
      available_on: "2010-04-17 14:00:00.000000Z",
      description: "some description",
      discontinue_on: "2010-04-17 14:00:00.000000Z",
      meta_description: "some meta_description",
      meta_keywords: "some meta_keywords",
      meta_title: "some meta_title",
      name: "some name",
      promotionable: true,
      slug: "some slug"
    }
    @update_attrs %{
      available_on: "2011-05-18 15:01:01.000000Z",
      description: "some updated description",
      discontinue_on: "2011-05-18 15:01:01.000000Z",
      meta_description: "some updated meta_description",
      meta_keywords: "some updated meta_keywords",
      meta_title: "some updated meta_title",
      name: "some updated name",
      promotionable: false,
      slug: "some updated slug"
    }
    @invalid_attrs %{
      available_on: nil,
      description: nil,
      discontinue_on: nil,
      meta_description: nil,
      meta_keywords: nil,
      meta_title: nil,
      name: nil,
      promotionable: nil,
      slug: nil
    }

    # def product_fixture(attrs \\ %{}) do
    #   {:ok, product} =
    #     attrs
    #     |> Enum.into(@valid_attrs)
    #     |> Context.create_product()
    #
    #   product
    # end
  end
end
