module View.Manage exposing (view)

import Browser exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Route exposing (routeToString)
import Types exposing (..)
import UIKit
import Url exposing (..)
import View.Lorem as Lorem


view : Model -> Html msg
view model =
    div [ class "manage-pane" ]
        [ p [] [ text "This page allows you to manage the properties of your Data Products." ]
        , p [] [ text "Data Products can be published provided they meet the minimum established criteria. In this case, they must have both a Description and an owner." ]
        , h2 [] [ text "Kafka Topics" ]
        , Lorem.lorem1
        ]
