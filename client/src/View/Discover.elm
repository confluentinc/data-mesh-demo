module View.Discover exposing (view)

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
    div [ class "discover-pane" ]
        [ div [ class "discover-main" ]
            [ h2 [] [ text "Data Products" ]
            , Lorem.lorem2
            ]
        , div [ class "discover-detail" ]
            [ h2 [] [ text "Data Products Information" ]
            , Lorem.lorem3
            ]
        , div [ class "discover-copy" ]
            [ p [] [ text "Discover the data products that are relevant to your domain." ]
            , p [] [ text "Data Product information contains all the relevant info about this product. You can view schemas, ownership, description, and lineage information." ]
            , p [] [ text "You can also export the data product to your own external data store for use by individual applications." ]
            ]
        ]
