module View.Common exposing (errorToString, webDataView)

import Html exposing (..)
import Http
import RemoteData exposing (RemoteData(..), WebData)


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
            text "TODO Data Not Loading"

        Loading ->
            text "TODO Data Loading"

        Failure err ->
            text ("TODO Data Load Failed " ++ errorToString err)

        Success result ->
            successView result
