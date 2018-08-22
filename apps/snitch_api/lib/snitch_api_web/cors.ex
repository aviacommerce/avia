defmodule ApiWeb.CORS do
  @moduledoc false

  use Corsica.Router,
    origins: ["http://localhost:4200", "http://localhost:4000"],
    log: [rejected: :error],
    allow_credentials: true,
    allow_headers: ["content-type", "token-type", "authorization"],
    allow_methods: ["GET", "PUT", "OPTIONS", "DELETE"],
    max_age: 600

  resource("/*")
end
