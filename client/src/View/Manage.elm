module View.Manage exposing (publishDialog, view)

import Browser exposing (..)
import Dialog.Common as Dialog
import GenericDict as Dict
import Html exposing (..)
import Html.Attributes exposing (autofocus, checked, class, disabled, name, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Markdown
import Maybe exposing (withDefault)
import RemoteData exposing (RemoteData(..), WebData)
import Result.Extras as Result
import Route exposing (routeToString)
import Table exposing (defaultCustomizations)
import Table.Extras as Table
import Types exposing (..)
import UIKit
import Url exposing (..)
import Validate exposing (validate)
import View.Common exposing (..)


view : Model -> Html Msg
view model =
    div [ class "manage-pane" ]
        [ Markdown.toHtml [] manageCopy
        , h2 []
            [ text "Kafka Topics"
            , p [] [ small [] [ text "To publish as data products" ] ]
            ]
        , case model.deleteResult of
            Failure err ->
                errorView err

            _ ->
                span [] []
        , webDataView
            (Dict.values
                >> Table.view
                    tableConfig
                    model.dataProductsTableState
            )
            model.streams
        ]


manageCopy : String
manageCopy =
    """
This page allows you to manage the properties of your Data Products.

Data Products can be published provided they meet the minimum
established criteria. In this case, they must have both a Description
and an owner.
"""


tableConfig : Table.Config Stream Msg
tableConfig =
    Table.customConfig
        { toId = streamQualifiedName >> unQualifiedName
        , toMsg = SetDataProductsTableState
        , columns =
            [ Table.stringColumn "Name" getStreamName
            , Table.stringColumn "Domain" (getStreamDomain >> withDefault "-")
            , Table.stringColumnWithAttributes
                "Description"
                [ class "description" ]
                (getStreamDescription >> withDefault "-")
            , Table.stringColumn "Owner" (getStreamOwner >> withDefault "-")
            , Table.stringColumn "Quality" (getStreamQuality >> maybe "-" showProductQuality)
            , Table.stringColumn "SLA" (getStreamSLA >> maybe "-" showProductSla)
            , Table.veryCustomColumn
                { name = "Data Product"
                , viewData =
                    \dataProduct ->
                        Table.HtmlDetails []
                            [ publishButton dataProduct ]
                , sorter =
                    Table.increasingOrDecreasingBy
                        (\stream ->
                            case stream of
                                StreamDataProduct _ ->
                                    0

                                StreamTopic _ ->
                                    1
                        )
                }
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
                , UIKit.width_1_1
                , UIKit.buttonDanger
                , onClick (DeleteDataProduct dataProduct.qualifiedName)
                ]
                [ text "Remove from Mesh" ]

        StreamTopic topic ->
            button
                [ UIKit.button
                , UIKit.width_1_1
                , UIKit.buttonPrimary
                , onClick (StartPublishDialog topic.qualifiedName)
                ]
                [ text "Add to Mesh" ]


publishDialog : WebData PublishFormResult -> PublishForm -> Dialog.Config Msg
publishDialog result model =
    let
        validationResult =
            validate publishFormValidator model

        hasOwnerValidationErrors =
            case validationResult of
                Ok _ ->
                    False

                Err errs ->
                    List.member RestrictedOwner errs
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
                    [ fieldset
                        [ UIKit.fieldset
                        , disabled (RemoteData.isLoading result)
                        ]
                        [ div []
                            [ label [ UIKit.formLabel ] [ text "Domain" ]
                            , div [ UIKit.formControls ]
                                [ input
                                    [ type_ "text"
                                    , UIKit.input
                                    , placeholder "Data Product Domain"
                                    , autofocus True
                                    , value model.domain
                                    , onInput (PublishFormMsg << PublishFormSetDomain)
                                    ]
                                    []
                                ]
                            ]
                        , div []
                            [ label [ UIKit.formLabel ] [ text "Owner" ]
                            , div [ UIKit.formControls ]
                                [ input
                                    ([ type_ "text"
                                     , UIKit.input
                                     , placeholder "Data Product Owner"
                                     , autofocus True
                                     , value model.owner
                                     , onInput (PublishFormMsg << PublishFormSetOwner)
                                     ]
                                        ++ (if hasOwnerValidationErrors then
                                                [ UIKit.formDanger ]

                                            else
                                                []
                                           )
                                    )
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
                                    , onInput (PublishFormMsg << PublishFormSetDescription)
                                    ]
                                    []
                                ]
                            ]
                        , radioButtonGroup
                            "Quality"
                            (PublishFormMsg << PublishFormSetQuality)
                            showProductQuality
                            (Just model.quality)
                            allProductQualities
                        , radioButtonGroup
                            "SLA"
                            (PublishFormMsg << PublishFormSetSla)
                            showProductSla
                            (Just model.sla)
                            allProductSlas
                        ]
                    ]
                , case validationResult of
                    Ok _ ->
                        span [] []

                    Err validationErrors ->
                        div [ UIKit.alert, UIKit.alertDanger ]
                            (List.map formatValidationError validationErrors)
                ]
            )
    , footer =
        Just
            (div []
                [ button
                    [ UIKit.button
                    , UIKit.buttonDefault
                    , UIKit.modalClose
                    , disabled (RemoteData.isLoading result)
                    , onClick AbandonPublishDialog
                    ]
                    [ text "Cancel" ]
                , button
                    [ UIKit.button
                    , UIKit.buttonPrimary
                    , disabled (RemoteData.isLoading result || Result.isErr validationResult)
                    , onClick (PublishDataProduct model)
                    ]
                    [ text "Publish" ]
                ]
            )
    }


radioButtonGroup : String -> (a -> msg) -> (a -> String) -> Maybe a -> List a -> Html msg
radioButtonGroup radioName handler toStr activeRadioValue radioValues =
    div []
        [ div [ UIKit.formLabel ] [ text radioName ]
        , div [ UIKit.formControls, UIKit.formControlsText ]
            (radioValues
                |> List.map
                    (radioButtonInput
                        radioName
                        handler
                        toStr
                        activeRadioValue
                    )
                |> List.intersperse (text nbsp)
            )
        ]


radioButtonInput : String -> (a -> msg) -> (a -> String) -> Maybe a -> a -> Html msg
radioButtonInput radioName handler toStr activeRadioValue radioValue =
    label []
        [ input
            [ type_ "radio"
            , name radioName
            , UIKit.radio
            , value (toStr radioValue)
            , onInput (always (handler radioValue))
            , checked (activeRadioValue == Just radioValue)
            ]
            []
        , text nbsp
        , text (toStr radioValue)
        ]


getStreamName : Stream -> String
getStreamName stream =
    case stream of
        StreamDataProduct dataProduct ->
            dataProduct.name

        StreamTopic topic ->
            topic.name


getStreamDomain : Stream -> Maybe String
getStreamDomain =
    getDataProduct >> Maybe.map .domain


getStreamDescription : Stream -> Maybe String
getStreamDescription =
    getDataProduct >> Maybe.map .description


getStreamOwner : Stream -> Maybe String
getStreamOwner =
    getDataProduct >> Maybe.map .owner


getStreamQuality : Stream -> Maybe ProductQuality
getStreamQuality =
    getDataProduct >> Maybe.map .quality


getStreamSLA : Stream -> Maybe ProductSla
getStreamSLA =
    getDataProduct >> Maybe.map .sla


maybe : b -> (a -> b) -> Maybe a -> b
maybe default fn =
    Maybe.map fn >> Maybe.withDefault default


getDataProduct : Stream -> Maybe DataProduct
getDataProduct stream =
    case stream of
        StreamDataProduct dataProduct ->
            Just dataProduct

        StreamTopic topic ->
            Nothing


formatValidationError : PublishFormError -> Html msg
formatValidationError error =
    case error of
        RestrictedOwner ->
            text "That owner is reserved. Please choose another."
