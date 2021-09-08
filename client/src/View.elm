module View exposing (view)

import Browser exposing (..)
import Dialog.UIKit as Dialog
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Route exposing (routeToString)
import Types exposing (..)
import UIKit
import Url exposing (..)
import View.Create
import View.Discover
import View.Manage


view : Model -> Document Msg
view model =
    { title = "Data Mesh"
    , body =
        [ headerView model.flags.images.logo
        , mainView model
        , Dialog.view
            (Maybe.map (View.Manage.publishDialog model.publishFormResult) model.publishForm)
        ]
    }


headerView : String -> Html msg
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


mainView : Model -> Html Msg
mainView model =
    div [ class "main" ]
        [ div [ UIKit.container ]
            [ ul
                [ UIKit.tab ]
                (List.map (tabView model.activeView)
                    [ ( Discover Nothing, "Discover & Export" )
                    , ( Create Nothing, "Create" )
                    , ( Manage, "Manage & Publish" )
                    ]
                )
            , case model.activeView of
                Discover mQualifiedName ->
                    View.Discover.view mQualifiedName model

                Create mName ->
                    View.Create.view mName model

                Manage ->
                    View.Manage.view model

                NotFound ->
                    notFoundView model
            ]
        ]


tabView : View -> ( View, String ) -> Html Msg
tabView activeView ( tab, label ) =
    li [ classList [ ( "uk-active", activeView == tab ) ] ]
        [ a [ href (routeToString tab) ] [ text label ] ]


notFoundView : Model -> Html msg
notFoundView model =
    h2 [] [ text "Not Found" ]
