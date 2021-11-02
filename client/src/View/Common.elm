module View.Common exposing
    ( errorView
    , loadingWheel
    , nbsp
    , selectable
    , showProductQuality
    , showProductSla
    , webDataView
    )

import Html exposing (..)
import Html.Attributes exposing (class)
import Http
import RemoteData exposing (RemoteData(..), WebData)
import Types exposing (ProductQuality(..), ProductSla(..))
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
            errorView err

        Success result ->
            successView result


errorView : Http.Error -> Html msg
errorView err =
    div [ UIKit.alert, UIKit.alertDanger ]
        [ h4 [] [ text "Data Load Failed" ]
        , p [] [ text (errorToString err) ]
        , p [] [ text "Check your network connection and try again." ]
        ]


loadingWheel : Html msg
loadingWheel =
    div [ class "loading-wheel" ]
        [ i [] [ text "Loading..." ]
        ]


nbsp : String
nbsp =
    " "


showProductQuality : ProductQuality -> String
showProductQuality quality =
    case quality of
        Authoritative ->
            "Authoritative"

        Curated ->
            "Curated"

        Raw ->
            "Raw"

        OtherQuality s ->
            s


showProductSla : ProductSla -> String
showProductSla sla =
    case sla of
        Tier1 ->
            "Tier 1"

        Tier2 ->
            "Tier 2"

        Tier3 ->
            "Tier 3"

        OtherSla s ->
            s


selectable : Attribute msg
selectable =
    class "selectable"
