defmodule Snitch.Tools.Cldr do
  use Cldr,
    locales: ["en"],
    default_locale: "en",
    providers: [Cldr.Number, Money]
end
