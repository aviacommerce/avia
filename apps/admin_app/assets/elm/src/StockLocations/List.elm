module StockLocations.List exposing (..)

import Html exposing (Html, a, button, div, h2, h3, img, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, colspan, href, scope, src)
import Http
import Json.Decode exposing (Decoder, at, bool, field, int, list, map4, string)
import RemoteData exposing (WebData)
import StockLocations.ListItem as SLItem


type alias Model =
    { stockLocations : WebData (List SLItem.Model) }


init : ( Model, Cmd Msg )
init =
    ( { stockLocations = RemoteData.NotAsked }, Cmd.none )


type Msg
    = SendHttpRequest
    | DataReceived (WebData (List SLItem.Model))



-- sendRequest :                            Request a -> Cmd (WebData a)
-- send        : (Result Error a -> msg) -> Request a -> Cmd msg


httpCommand : Cmd Msg
httpCommand =
    list stockLocationsDecoder
        |> at [ "data" ]
        |> Http.get "api/stock_locations"
        |> RemoteData.sendRequest
        |> Cmd.map DataReceived


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SendHttpRequest ->
            ( { model | stockLocations = RemoteData.Loading }, httpCommand )

        DataReceived response ->
            ( { model | stockLocations = response }, Cmd.none )


viewStockLocationsOrError : Model -> Html Msg
viewStockLocationsOrError model =
    case model.stockLocations of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            tr []
                [ td [ colspan 4, class "text-center" ]
                    [ div [ class "loader" ] []
                    ]
                ]

        RemoteData.Success stocklocations ->
            tbody [] (renderStockLocations stocklocations)

        RemoteData.Failure httpError ->
            viewError (createErrorMessage httpError)


viewError : String -> Html Msg
viewError errorMessage =
    let
        errorHeading =
            "Couldn't fetch data at this time."
    in
    tr []
        [ td [ colspan 4, class "text-center" ]
            [ h3 [] [ text errorHeading ]
            , text ("Error: " ++ errorMessage)
            ]
        ]


createErrorMessage : Http.Error -> String
createErrorMessage httpError =
    case httpError of
        Http.BadUrl message ->
            message

        Http.Timeout ->
            "Server is taking too long to respond. Please try again later."

        Http.NetworkError ->
            "It appears you don't have an Internet connection right now."

        Http.BadStatus response ->
            response.status.message

        Http.BadPayload message response ->
            message


initialModel : Model
initialModel =
    { stockLocations = RemoteData.Loading }


stockLocationsDecoder : Decoder SLItem.Model
stockLocationsDecoder =
    map4 SLItem.Model
        (field "id" int)
        (field "id" int)
        (field "name" string)
        (field "active" bool)


renderStockLocation : SLItem.Model -> Html a
renderStockLocation stockLocation =
    SLItem.view stockLocation


renderStockLocations : List SLItem.Model -> List (Html a)
renderStockLocations stockLocations =
    List.indexedMap (\i x -> renderStockLocation { x | sno = i + 1 }) stockLocations


view : Model -> Html Msg
view model =
    div [ class "StockLocations--container list-container" ]
        [ div [ class "row m-0 list-header" ]
            [ div [class "col-10 p-0"]
                [ h2 []
                    [ text "Stock Location List"
                    ]
                ]
            , div [class "col-2 p-0 float-right text-right"]
                [ a [ href "/stock_locations/new", class "btn btn-primary float-right" ] [ text "Create Stock Location" ]
                ]
            ]
        , div [ class "row m-0 list" ]
            [ table [ class "StockLocations__List table" ]
                [ thead [ class "thead-light" ]
                    [ tr []
                        [ th [ class "col1" ] [ text "#" ]
                        , th [ class "col2" ] [ text "Name" ]
                        , th [ class "col3" ] [ text "Status" ]
                        , th [ class "col4" ] [ text "Action" ]
                        ]
                    ]
                , viewStockLocationsOrError model
                ]
            ]
        ]
