defmodule Avia.Etsy.Importer do
  @request_token_url "https://openapi.etsy.com/v2/oauth/request_token"
  @access_token_url "https://openapi.etsy.com/v2/oauth/access_token"
  @resource_base_url "https://openapi.etsy.com/v2"

  @oauth_secret "etsy_oauth_secret"
  @access_token "etsy_access_token"
  @access_token_secret "etsy_access_token_secret"

  @start_page_number 1
  @store "etsy"

  @store_consumer_key "ETSY_CONSUMER_KEY"
  @store_consumer_secret "ETSY_CONSUMER_SECRET"

  alias Snitch.Data.Model.StoreProps
  alias Snitch.Data.Model.Image, as: ImageModel
  alias Snitch.Tools.Helper.Taxonomy, as: TaxonomyHelper
  alias Snitch.Repo
  alias Snitch.Data.Schema.{Product, Taxon, Image}
  alias Snitch.Data.Schema.Taxonomy, as: TaxonomySchema
  alias Snitch.Tools.Helper.ImageUploader
  alias Snitch.Domain.Taxonomy

  def import do
    with {:ok, user} <- get_user(),
         {:ok, shop} <- get_user_shops(user["user_id"]) do
      products_import(@start_page_number, shop["shop_id"])
    end
  end

  def products_import(page_number, shop_id) do
    with {:ok, listings_response} <- get_shop_listing(shop_id, page_number, :active) do
      import_products(listings_response, "active")
      next_page = listings_response["pagination"]["next_page"]

      if(next_page != nil) do
        products_import(next_page, shop_id)
      end
    end
  end

  def insert_taxonomy(parent, []) do
    parent
  end

  def insert_taxonomy(parent, [head | t]) do
    case Taxonomy.get_taxon_by_name(head) do
      %Taxon{id: id} = taxon ->
        insert_taxonomy(taxon, t)

      nil ->
        new_taxon =
          Taxonomy.add_taxon(parent |> Repo.preload(:taxonomy), %Taxon{name: head}, :child)

        insert_taxonomy(new_taxon, t)
    end
  end

  def create_taxon_node(etsy_node) do
    {etsy_node["name"], etsy_node["children"] |> Enum.map(&create_taxon_node/1)}
  end

  defp import_products(listing_json, product_state) do
    # Right now we are not supporting the variants import
    # so dropping the listing with variation
    listings =
      listing_json["results"]
      |> Enum.filter(fn listing -> listing["has_variations"] == false end)

    imported_products =
      listings
      |> Enum.map(fn listing -> listing["listing_id"] end)
      |> Enum.map(fn listing_id -> save_product(listing_id, product_state) end)
  end

  defp save_product(listing_id, product_state) do
    {:ok, listing_json} = get_listing_product_inventory(listing_id)

    {:ok, inventory_json} = get_listing_inventory(listing_id)

    avia_product =
      inventory_json["results"]["products"]
      |> Enum.map(fn x -> map_listing(listing_json["results"], product_state, x) end)
      |> List.first()

    {_, product} = Repo.insert_all(Product, [product(avia_product)], returning: [:id])

    save_images(listing_json, product |> List.first())
  end

  defp product(avia_product) do
    avia_product
    |> Map.take([
      :name,
      :description,
      :sku,
      :selling_price,
      :max_retail_price,
      :state,
      :slug,
      :taxon_id,
      :store,
      :import_product_id
    ])
    |> Map.merge(timestamps)
  end

  defp timestamps() do
    %{
      inserted_at: Ecto.DateTime.utc(),
      updated_at: Ecto.DateTime.utc()
    }
  end

  defp map_listing(listing, product_state, etsy_product) do
    taxonomy = Repo.all(TaxonomySchema) |> Repo.preload(:root) |> List.first()
    root_taxon = taxonomy.root
    listing = List.first(listing)

    product_taxon = insert_taxonomy(root_taxon, listing["taxonomy_path"])

    product = %{
      name: listing["title"],
      slug: get_slug(listing["url"], listing["listing_id"]),
      description: listing["description"],
      sku: List.first(listing["sku"]) || "",
      selling_price: Money.new(listing["price"], listing["currency_code"]),
      max_retail_price: Money.new(listing["price"], listing["currency_code"]),
      state: product_state,
      taxon_id: product_taxon.id,
      import_product_id: "#{etsy_product["product_id"]}",
      has_variants: listing["has_variations"],
      listing_id: listing["listing_id"],
      store: @store
    }
  end

  defp save_images(listing_details, product) do
    result = listing_details["results"] |> List.first()
    images_json = result["Images"]

    images =
      images_json
      |> Enum.map(fn x -> upload_image(x, product) end)

    image = images |> Enum.map(fn x -> create_image(x) end)

    Product.associate_image_changeset(product, image) |> Repo.update!()
  end

  def upload_image(img_json, product) do
    {file_path, file_name} = download_image(img_json["url_fullxfull"], "/temp/")

    upload = %Plug.Upload{
      content_type: "image/jpg",
      filename: file_name,
      path: file_path
    }

    {:ok, filename} = ImageModel.store(upload, product)
    filename
  end

  defp create_image(image) do
    %Image{name: image} |> Repo.insert!()
  end

  def download_image(image_url, base_path) do
    case HTTPoison.get(image_url) do
      {:ok, %HTTPoison.Response{body: body}} ->
        file_name = String.split(image_url, "/") |> List.last()
        file_path = Application.app_dir(:admin_app) <> "/" <> file_name
        File.write(file_path, body)
        {file_path, file_name}

      _ ->
        {:error, :download_failed}
    end
  end

  # Right now using the slug from URL as it is
  # Some times the URL slug are same but the listing id is different
  defp get_slug(path, listing_id) do
    uri = URI.parse(path)
    slug = String.split(uri.path, "/") |> List.last()
    "#{listing_id}-#{slug}"
  end

  defp get_product_offering_price(product) do
    # TODO Use offering where the Avia Store currency matches
    case product["offerings"] |> List.first() do
      nil -> 0
      offering -> offering["price"]["currency_formatted_raw"]
    end
  end

  # TODO Use the same offering price where the offering matches, so that we dont
  # get_product_offering_price/1 method to sepratel get the price.
  defp get_product_offering_currency(product) do
    case product["offerings"] |> List.first() do
      nil -> :USD
      offering -> offering["price"]["currency_code"]
    end
  end

  defp get_user() do
    with {:ok, body} <- request_resource("get", "/users/__SELF__"),
         {:ok, json} <- Jason.decode(body) do
      user = json |> Map.get("results") |> List.first()

      {:ok, user}
    end
  end

  defp get_user_shops(user_id) do
    with {:ok, body} <- request_resource("get", "/users/#{user_id}/shops"),
         {:ok, json} <- Jason.decode(body) do
      shop = json |> Map.get("results") |> List.first()

      {:ok, shop}
    end
  end

  defp get_listing_product_inventory(listing_id) do
    with {:ok, body} <- request_resource("get", "/listings/#{listing_id}?includes=Images"),
         {:ok, json} <- Jason.decode(body) do
      {:ok, json}
    end
  end

  # /listings/active?api_key=
  # /shops/#{shop_id}/listings/active?page=#{page_number}
  # You can swap the above URL's if you want to test importer with large data
  def get_shop_listing(shop_id, page_number, :active) do
    with {:ok, body} <-
           request_resource("get", "/shops/#{shop_id}/listings/active?page=#{page_number}"),
         {:ok, json} <- Jason.decode(body) do
      {:ok, json}
    end
  end

  def get_listing_inventory(listing_id) do
    with {:ok, body} <-
           request_resource(
             "get",
             "/listings/#{listing_id}/inventory?write_missing_inventory=true"
           ),
         {:ok, json} <- Jason.decode(body) do
      {:ok, json}
    end
  end

  defp save_oauth_secret(oauth_secret) do
    StoreProps.store(@oauth_secret, oauth_secret)
  end

  def get_app_keys do
    with {:ok, consumer_key} <- get_key(@store_consumer_key),
         {:ok, consumer_secret} <- get_key(@store_consumer_secret) do
      {:ok, consumer_key, consumer_secret}
    else
      {:error, :not_found} -> {:error, :invalid_key}
    end
  end

  def get_key(keyname) do
    case System.get_env(keyname) do
      nil -> {:error, :not_found}
      value -> {:ok, value}
    end
  end

  def get_access_token(
        consumer_key,
        consumer_secret,
        oauth_token,
        oauth_token_secret,
        oauth_verifier
      ) do
    creds =
      OAuther.credentials(
        consumer_key: consumer_key,
        consumer_secret: consumer_secret,
        token: oauth_token,
        token_secret: oauth_token_secret
      )

    params = OAuther.sign("get", @access_token_url, [{"oauth_verifier", oauth_verifier}], creds)

    {headers, req_params} = OAuther.header(params)

    case :hackney.get(@access_token_url, [headers], {:form, req_params}) do
      {:ok, 200, _, client_ref} ->
        body =
          client_ref
          |> get_response
          |> URI.decode_query()

        {:ok, body}

      _ ->
        {:error, :request_failed}
    end
  end

  def authorize_app(consumer_key, consumer_secret, request_token_url, callback_url) do
    creds = OAuther.credentials(consumer_key: consumer_key, consumer_secret: consumer_secret)

    params = OAuther.sign("get", request_token_url, [{"oauth_callback", callback_url}], creds)

    {headers, req_params} = OAuther.header(params)

    case :hackney.get(request_token_url, [headers], {:form, req_params}) do
      {:ok, 200, _, client_ref} ->
        body =
          client_ref
          |> get_response()
          |> URI.decode_query()

        {:ok, body}

      _ ->
        {:error, :request_failed}
    end
  end

  def request_resource(method, uri, headers \\ []) do
    url = @resource_base_url <> uri

    {:ok, creds} = get_credentials()

    params = OAuther.sign(method, url, [], creds)

    {req_headers, req_params} = OAuther.header(params)

    case :hackney.request(method, url, [req_headers], {:form, req_params}) do
      {:ok, 200, _, client_ref} ->
        {:ok, get_response(client_ref)}

      _ ->
        {:error, :request_failed}
    end
  end

  defp get_credentials() do
    with {:ok, consumer_key, consumer_secret} <- get_app_keys(),
         {:ok, access_token_prop, access_token_secret_prop} <- get_access_tokens() do
      creds =
        OAuther.credentials(
          consumer_key: consumer_key,
          consumer_secret: consumer_secret,
          token: access_token_prop.value,
          token_secret: access_token_secret_prop.value
        )

      {:ok, creds}
    end
  end

  def get_access_tokens() do
    with {:ok, access_token} <- StoreProps.get(@access_token),
         {:ok, access_token_secret} <- StoreProps.get(@access_token_secret) do
      {:ok, access_token, access_token_secret}
    end
  end

  def get_callback_url() do
    AdminAppWeb.Endpoint.url() <> "/product/import/etsy/callback"
  end

  defp get_response(client_ref) do
    case :hackney.body(client_ref) do
      {:ok, body} -> body
    end
  end
end
