module Dialog.UIKit exposing (..)

import Dialog.Common exposing (Config, empty, isJust, maybe)
import Html exposing (..)
import Html.Attributes exposing (class, classList, style)
import Html.Events exposing (..)
import Svg exposing (line, svg)
import Svg.Attributes exposing (fill, height, stroke, strokeWidth, viewBox, width, x1, x2, y1, y2)


view : Maybe (Config msg) -> Html msg
view maybeConfig =
    let
        displayed =
            isJust maybeConfig
    in
    div
        (case
            maybeConfig
                |> Maybe.andThen .containerClass
         of
            Nothing ->
                []

            Just containerClass ->
                [ class containerClass ]
        )
        [ div
            [ classList
                [ ( "uk-modal", True )
                , ( "uk-open", displayed )
                ]
            , style "display"
                (if displayed then
                    "block"

                 else
                    "none"
                )
            ]
            [ div [ class "uk-modal-dialog" ]
                (case maybeConfig of
                    Nothing ->
                        [ empty ]

                    Just config ->
                        [ wrapHeader config.closeMessage config.header
                        , maybe empty wrapBody config.body
                        , maybe empty wrapFooter config.footer
                        ]
                )
            ]
        ]


wrapHeader : Maybe msg -> Maybe (Html msg) -> Html msg
wrapHeader closeMessage header =
    if closeMessage == Nothing && header == Nothing then
        empty

    else
        div [ class "uk-modal-header" ]
            [ maybe empty closeButton closeMessage
            , Maybe.withDefault empty header
            ]


closeButton : msg -> Html msg
closeButton closeMessage =
    button
        [ class "uk-modal-close-default"
        , class "uk-icon"
        , class "uk-close"
        , onClick closeMessage
        ]
        [ svg
            [ width "14"
            , height "14"
            , viewBox "0 0 14 14"
            ]
            [ line
                [ fill "none"
                , stroke "#000"
                , strokeWidth "1.1"
                , x1 "1"
                , y1 "1"
                , x2 "13"
                , y2 "13"
                ]
                []
            , line
                [ fill "none"
                , stroke "#000"
                , strokeWidth "1.1"
                , x1 "13"
                , y1 "1"
                , x2 "1"
                , y2 "13"
                ]
                []
            ]
        ]


wrapBody : Html msg -> Html msg
wrapBody body =
    div [ class "uk-modal-body" ]
        [ body ]


wrapFooter : Html msg -> Html msg
wrapFooter footer =
    div
        [ class "uk-modal-footer"
        , class "uk-text-right"
        ]
        [ footer ]
