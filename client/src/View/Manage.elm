module View.Manage exposing (publishDialog, view)

import Browser exposing (..)
import Dialog.Common as Dialog
import GenericDict as Dict
import Html exposing (..)
import Html.Attributes exposing (autofocus, class, disabled, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import RemoteData exposing (RemoteData(..))
import Route exposing (routeToString)
import Table exposing (defaultCustomizations)
import Types exposing (..)
import UIKit
import Url exposing (..)
import View.Common exposing (webDataView)
import View.Lorem as Lorem


view : Model -> Html Msg
view model =
    div [ class "manage-pane" ]
        [ p [] [ text "This page allows you to manage the properties of your Data Products." ]
        , p [] [ text "Data Products can be published provided they meet the minimum established criteria. In this case, they must have both a Description and an owner." ]
        , h2 [] [ text "Kafka Topics" ]
        , webDataView
            (Dict.values
                >> Table.view
                    tableConfig
                    model.dataProductsTableState
            )
            model.dataProducts
        ]


tableConfig : Table.Config DataProduct Msg
tableConfig =
    Table.customConfig
        { toId = .qualifiedName >> unQualifiedName
        , toMsg = SetDataProductsTableState
        , columns =
            [ Table.stringColumn "Name" .name
            , Table.veryCustomColumn
                { name = "Data Product"
                , viewData =
                    \dataProduct ->
                        Table.HtmlDetails []
                            [ publishButton dataProduct ]
                , sorter = Table.unsortable
                }
            , Table.stringColumn "Description" .description
            , Table.stringColumn "Owner" .owner
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


publishButton : DataProduct -> Html Msg
publishButton dataProduct =
    case
        dataProduct.isPublished
    of
        Success True ->
            button
                [ UIKit.button
                , disabled True
                ]
                [ text "Published" ]

        Success False ->
            button
                [ UIKit.button
                , UIKit.buttonPrimary
                , onClick (StartPublishDialog dataProduct.qualifiedName)
                ]
                [ text "Publish" ]

        Loading ->
            button
                [ UIKit.button
                , disabled True
                ]
                [ i [] [ text "Publishing..." ] ]

        _ ->
            button
                [ UIKit.button
                , disabled True
                ]
                [ text "TODO ???" ]


publishDialog : PublishModel -> Dialog.Config Msg
publishDialog model =
    { closeMessage = Just AbandonPublishDialog
    , containerClass = Nothing
    , header =
        Just
            (div [ UIKit.modalTitle ]
                [ text "Publish" ]
            )
    , body =
        Just
            (div []
                [ p []
                    [ text "Enter the required Data Product tags." ]
                , form [ UIKit.formHorizontal ]
                    [ div []
                        [ label [ UIKit.formLabel ] [ text "Name" ]
                        , div [ UIKit.formControls ]
                            [ input
                                [ type_ "text"
                                , UIKit.input
                                , placeholder "Data Product Name"
                                , autofocus True
                                , value model.name
                                , onInput (PublishDialogMsg << PublishDialogSetName)
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
                                , onInput (PublishDialogMsg << PublishDialogSetDescription)
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
                    , onClick AbandonPublishDialog
                    ]
                    [ text "Cancel" ]
                , button
                    [ UIKit.button
                    , UIKit.buttonPrimary
                    , onClick (PublishDataProduct model)
                    ]
                    [ text "Publish" ]
                ]
            )
    }
