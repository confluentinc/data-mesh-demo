module View.Tooltips exposing (tooltip)

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class)
import View.Icons exposing (Icon(..), icon)


tooltip : String -> Html msg
tooltip contents =
    span [ class "tooltip-container" ]
        [ icon Info
        , div [ class "tooltip" ]
            [ div [ class "tooltip-contents" ]
                [ text contents ]
            ]
        ]
