defmodule Snitch.Data.Model.ProductBrandTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.{Image, ProductBrand}
  alias Snitch.Data.Model.ProductBrand, as: PBModel
  alias Snitch.Data.Model.Image, as: ImageModel
  alias Snitch.Repo

  @img "test/support/image.png"
  @img_new "test/support/image_new.png"

  setup do
    valid_params = %{
      "name" => "yolo"
    }

    product_brand = insert(:product_brand)

    image_params = %{
      type: "image/png",
      filename: "3Lu6PTMFSHz8eQfoGCP3F.png",
      path: @img
    }

    invalid_params = %{
      "name" => nil
    }

    [
      valid_params: valid_params,
      invalid_params: invalid_params,
      image_params: image_params,
      product_brand: product_brand
    ]
  end

  describe "create product brand" do
    test "successfully along with image", %{image_params: ip, valid_params: vp} do
      vp = vp |> Map.put("image", ip)
      assert {:ok, product_brand} = PBModel.create(vp)
      ImageModel.delete_image(ip.filename, product_brand)
    end

    test "successfully without image", %{valid_params: vp} do
      assert {:ok, product_brand} = PBModel.create(vp)
    end

    test "with invalid params", %{invalid_params: ip} do
      assert {:error, _} = PBModel.create(ip)
    end
  end

  describe "update product brand" do
    test "successfully along with image", %{image_params: ip, product_brand: pb} do
      new_image = %{
        type: "image/png",
        filename: "3Lu6PTMFSHz8eQfoGCCCC.png",
        path: @img_new
      }

      pb = pb |> Repo.preload(:image)
      params = %{} |> Map.put("image", new_image)
      assert {:ok, product_brand} = PBModel.update(pb, params)
      ImageModel.delete_image(new_image.filename, product_brand)
    end

    test "successfully without image", %{product_brand: pb} do
      params = %{"name" => "new_store"}
      assert {:ok, product_brand} = PBModel.update(pb, params)
    end

    test "with invalid params", %{product_brand: pb} do
      params = %{"name" => nil}
      assert {:error, _} = PBModel.update(pb, params)
    end
  end

  describe "delete product brand" do
    test "with image", %{image_params: ip, valid_params: vp} do
      vp = vp |> Map.put("image", ip)
      {:ok, product_brand} = PBModel.create(vp)
      assert {:ok, "success"} = PBModel.delete(product_brand.id)
      ImageModel.delete_image(ip.filename, product_brand)
    end

    test "without image", %{product_brand: pb} do
      assert {:ok, product_brand} = PBModel.delete(pb.id)
    end
  end
end
