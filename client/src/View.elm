module View exposing (view)

import Browser exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Route exposing (routeToString)
import Types exposing (..)
import UIKit
import Url exposing (..)


view : Model -> Document Msg
view model =
    { title = "Data Mesh"
    , body =
        [ headerView model.logoPath
        , mainView model
        ]
    }


headerView logoPath =
    header []
        [ div [ UIKit.container ]
            [ img
                [ class "logo"
                , src logoPath
                ]
                []
            , h1 [] [ text "Confluent" ]
            ]
        ]


mainView model =
    div [ class "main" ]
        [ div [ UIKit.container ]
            [ ul
                [ UIKit.tab ]
                (List.map (tabView model.activeView)
                    [ ( Discover, "Discover & Export" )
                    , ( Create, "Create" )
                    , ( Manage, "Manage & Publish" )
                    ]
                )
            , case model.activeView of
                Discover ->
                    discoverView model

                Create ->
                    createView model

                Manage ->
                    manageView model

                NotFound ->
                    notFoundView model
            ]
        ]


tabView : View -> ( View, String ) -> Html Msg
tabView activeView ( tab, label ) =
    li [ classList [ ( "uk-active", activeView == tab ) ] ]
        [ a [ href (routeToString tab) ] [ text label ] ]


discoverView : Model -> Html msg
discoverView model =
    h2 [] [ text "Discover" ]


createView : Model -> Html msg
createView model =
    h2 [] [ text "Create" ]


manageView : Model -> Html msg
manageView model =
    h2 [] [ text "Manage" ]


notFoundView : Model -> Html msg
notFoundView model =
    h2 [] [ text "Not Found" ]
