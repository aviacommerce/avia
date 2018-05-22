module Routing exposing (..)

import Navigation exposing (Location)
import StockLoca
import UrlParser exposing (..)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map StockLocationsRoute top
        , map StockLocationRoute (s "stock_locations" </> string)
        ]


parseLocation : Location -> Route
parseLocation n =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


StockLocationsPath : String
StockLocationsPath =
    "#stock_locaitons"


StockLocationPath : PlayerId -> String
StockLocationPath id =
    "#stock_locations/" ++ id
