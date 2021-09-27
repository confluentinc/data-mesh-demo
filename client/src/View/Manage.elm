module View.Manage exposing (publishDialog, view)

import Browser exposing (..)
import Dialog.Common as Dialog
import GenericDict as Dict
import Html exposing (..)
import Html.Attributes exposing (autofocus, class, disabled, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import RemoteData exposing (RemoteData(..), WebData)
import Route exposing (routeToString)
import Table exposing (defaultCustomizations)
import Types exposing (..)
import UIKit
import Url exposing (..)
import View.Common exposing (webDataView,errorView)
import View.Lorem as Lorem


view : Model -> Html Msg
view model =
    div [ class "manage-pane" ]
        [ p [] [ text "This page allows you to manage the properties of your Data Products." ]
        , p [] [ text "Data Products can be published provided they meet the minimum established criteria. In this case, they must have both a Description and an owner." ]
        , h2 []
            [ text "Kafka Topics"
            , p [] [ small [] [ text "To publish as data products" ] ]
            ]
        , webDataView
            (Dict.values
                >> Table.view
                    tableConfig
                    model.dataProductsTableState
            )
            model.streams
        ]


tableConfig : Table.Config Stream Msg
tableConfig =
    Table.customConfig
        { toId = streamQualifiedName >> unQualifiedName
        , toMsg = SetDataProductsTableState
        , columns =
            [ Table.stringColumn "Name"
                (\stream ->
                    case stream of
                        StreamDataProduct dataProduct ->
                            dataProduct.name

                        StreamTopic topic ->
                            topic.name
                )
            , Table.veryCustomColumn
                { name = "Data Product"
                , viewData =
                    \dataProduct ->
                        Table.HtmlDetails []
                            [ publishButton dataProduct ]
                , sorter = Table.unsortable
                }
            , Table.stringColumn "Description"
                (\stream ->
                    case stream of
                        StreamDataProduct dataProduct ->
                            dataProduct.description

                        StreamTopic topic ->
                            "-"
                )
            , Table.stringColumn "Owner"
                (\stream ->
                    case stream of
                        StreamDataProduct dataProduct ->
                            dataProduct.owner

                        StreamTopic topic ->
                            "-"
                )
            , Table.stringColumn "Other Tags" (\_ -> "")
            ]
        , customizations =
            { defaultCustomizations
                | tableAttrs =
                    [ UIKit.table
                    , UIKit.tableDivider
                    , UIKit.tableStriped
                    , UIKit.tableSmall
                    ]
            }
        }


publishButton : Stream -> Html Msg
publishButton stream =
    case
        stream
    of
        StreamDataProduct dataProduct ->
            button
                [ UIKit.button
                , UIKit.buttonDanger
                , onClick (DeleteDataProduct dataProduct.qualifiedName)
                ]
                [ text "Unpublish" ]

        StreamTopic topic ->
            button
                [ UIKit.button
                , UIKit.buttonPrimary
                , onClick (StartPublishDialog topic.qualifiedName)
                ]
                [ text "Publish" ]


publishDialog : WebData PublishFormResult -> PublishForm -> Dialog.Config Msg
publishDialog result model =
    let
        disabledAttribute =
            disabled (RemoteData.isLoading result)
    in
    { closeMessage = Just AbandonPublishDialog
    , containerClass = Nothing
    , header =
        Just
            (div [ UIKit.modalTitle ]
                [ text ("Publish: " ++ model.topic.name) ]
            )
    , body =
        Just
            (div []
                [ p []
                    [ text "Enter the required Data Product tags." ]
                , case result of
                    Failure err ->
                        errorView err

                    Success _ ->
                        text ""

                    Loading ->
                        text ""

                    NotAsked ->
                        text ""
                , form [ UIKit.formHorizontal ]
                    [ div []
                        [ label [ UIKit.formLabel ] [ text "Owner" ]
                        , div [ UIKit.formControls ]
                            [ input
                                [ type_ "text"
                                , UIKit.input
                                , placeholder "Data Product Owner"
                                , autofocus True
                                , value model.owner
                                , disabledAttribute
                                , onInput (PublishFormMsg << PublishFormSetOwner)
                                ]
                                []
                            ]
                        ]
                    , div []
                        [ label [ UIKit.formLabel ] [ text "Description" ]
                        , div [ UIKit.formControls ]
                            [ input
                                [ type_ "text"
                                , UIKit.input
                                , placeholder "Data Product Description"
                                , value model.description
                                , disabledAttribute
                                , onInput (PublishFormMsg << PublishFormSetDescription)
                                ]
                                []
                            ]
                        ]
                    ]
                ]
            )
    , footer =
        Just
            (div []
                [ button
                    [ UIKit.button
                    , UIKit.buttonDefault
                    , UIKit.modalClose
                    , disabledAttribute
                    , onClick AbandonPublishDialog
                    ]
                    [ text "Cancel" ]
                , button
                    [ UIKit.button
                    , UIKit.buttonPrimary
                    , disabledAttribute
                    , onClick (PublishDataProduct model)
                    ]
                    [ text "Publish" ]
                ]
            )
    }
