module Main exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import StockLocations.List as StockLocationList


-- MODEL


type alias Model =
    { stockLocationListModel : StockLocationList.Model }


initialModel : Model
initialModel =
    { stockLocationListModel = StockLocationList.initialModel }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.map StockLocationListMsg StockLocationList.httpCommand )



-- UPDATE


type Msg
    = StockLocationListMsg StockLocationList.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StockLocationListMsg stockLocationMsg ->
            let
                ( updatedModel, cmd ) =
                    StockLocationList.update stockLocationMsg model.stockLocationListModel
            in
            ( { model | stockLocationListModel = updatedModel }, Cmd.map StockLocationListMsg cmd )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "elm-main" ]
        [ Html.map StockLocationListMsg (StockLocationList.view model.stockLocationListModel) ]


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
