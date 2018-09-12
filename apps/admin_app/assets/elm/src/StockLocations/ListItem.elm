module StockLocations.ListItem exposing (Model, view)

import Html exposing (Html, a, span, td, text, th, tr)
import Html.Attributes exposing (attribute, class, href, scope)


type alias Model =
    { sno : Int, id : Int, name : String, active : Bool }


renderStatus : Model -> Html a
renderStatus model =
    span
        [ class
            (if model.active then
                "badge badge-success"
             else
                "badge badge-danger"
            )
        ]
        [ text
            (if model.active then
                "Active"
             else
                "Inactive"
            )
        ]


view : Model -> Html a
view model =
    tr [ class "StockLocations__List__Item" ]
        [ td [] [ text (toString model.sno) ]
        , td [] [ a [ class "text-dark", href ("stock_locations/" ++ toString model.id) ] [ text model.name ] ]
        , td [] [ renderStatus model ]
        , td []
            [ a [ class "btn btn-sm fa fa-edit ", href ("stock_locations/" ++ toString model.id ++ "/edit"), attribute "data-icon" "edit" ] [ text "" ]
            ]
        ]
