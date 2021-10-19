module View.Icons exposing (Icon(..), icon)

import Html exposing (Html, span)
import Html.Attributes exposing (class)


type Icon
    = ExternalLink
    | Info


icon : Icon -> Html msg
icon iconType =
    let
        className =
            case iconType of
                ExternalLink ->
                    "icon-external-link"

                Info ->
                    "icon-info"
    in
    span [ class "icon", class className ] []
