module View.Common exposing
    ( errorToString
    , loadingWheel
    , webDataView
    )

import Html exposing (..)
import Html.Attributes exposing (class)
import Http
import RemoteData exposing (RemoteData(..), WebData)
import UIKit


errorToString : Http.Error -> String
errorToString err =
    case err of
        Http.BadUrl url ->
            "Bad URL: " ++ url

        Http.Timeout ->
            "Connection timed out"

        Http.NetworkError ->
            "Connection failed"

        Http.BadStatus statusCode ->
            "Error " ++ String.fromInt statusCode

        Http.BadBody body ->
            "Body rejected " ++ body


webDataView : (a -> Html msg) -> WebData a -> Html msg
webDataView successView webData =
    case webData of
        NotAsked ->
            loadingWheel

        Loading ->
            loadingWheel

        Failure err ->
            div [ UIKit.alert, UIKit.alertDanger ]
                [ h4 [] [ text "Data Load Failed" ]
                , p [] [ text (errorToString err) ]
                , p [] [ text "Check your network connection and try reloading." ]
                ]

        Success result ->
            successView result


loadingWheel : Html msg
loadingWheel =
    div [ class "loading-wheel" ]
        [ i [] [ text "Loading..." ]
        ]
