defmodule ApiWeb.CORS do
  @moduledoc false

  use Corsica.Router,
    origins: ["http://localhost:4200"],
    log: [rejected: :error],
    allow_credentials: true,
    allow_headers: ["content-type", "token-type"],
    allow_methods: ["GET", "OPTIONS"],
    max_age: 600

  resource("/*")
end
