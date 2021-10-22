module View.Manage exposing (publishDialog, view)

import Dialog.Common as Dialog
import GenericDict as Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (autofocus, checked, class, disabled, for, id, name, placeholder, type_, value)
import Html.Events exposing (onCheck, onClick, onInput)
import Markdown
import Maybe exposing (withDefault)
import RemoteData exposing (RemoteData(..), WebData)
import Result.Extras as Result
import Table exposing (defaultCustomizations)
import Table.Extras as Table
import Tuple exposing (pair)
import Types exposing (..)
import UIKit
import Validate exposing (validate)
import View.Common exposing (..)
import View.Tooltips exposing (tooltip)


view : Model -> Html Msg
view model =
    div [ class "manage-pane" ]
        [ header []
            [ Markdown.toHtml [] manageIntro ]
        , div [ class "manage-main" ]
            [ h2 []
                [ text "Kafka Topics"
                , p []
                    [ small []
                        [ text "Publishable as data products"
                        , tooltip "These event streams are fully within your domain, and can be published as event streams. Doing so will expose them publicly to all other domains in your org"
                        ]
                    ]
                ]
            , case model.deleteResult of
                Failure err ->
                    errorView err

                _ ->
                    span [] []
            , webDataView
                (splitStreamTablesView model.dataProductsTableState)
                (RemoteData.map2 pair model.streams model.actuatorInfo)
            ]
        , footer []
            [ Markdown.toHtml [] manageOutro ]
        ]


splitStreamTablesView : Table.State -> ( Dict QualifiedName Stream, ActuatorInfo ) -> Html Msg
splitStreamTablesView dataProductsTableState ( streams, actuatorInfo ) =
    let
        ( ourStreams, otherStreams ) =
            List.partition
                (\stream ->
                    case getStreamDomain stream of
                        Nothing ->
                            True

                        Just domain ->
                            domain == actuatorInfo.domain
                )
                (Dict.values streams)

        showTableUnlessEmpty tableConfigFlags items =
            if List.isEmpty items then
                span [] []

            else
                Table.view
                    (tableConfig tableConfigFlags)
                    dataProductsTableState
                    items
    in
    div []
        [ showTableUnlessEmpty
            { showControls = True
            , caption = Nothing
            }
            ourStreams
        , showTableUnlessEmpty
            { showControls = False
            , caption =
                Just
                    [ text "Data Products from other domains"
                    , tooltip "These are data products that have been published from other domains and are owned by other teams. You cannot perform any management operations on them as you do not have the necessary permissions"
                    ]
            }
            otherStreams
        ]


manageIntro : String
manageIntro =
    """
## Publish Data Products to the Data Mesh

*Role: Data Product Owner*

This tab allows you to manage the data products within your domain. There are two main tables:
- Your domain's Kafka Topics, that can be published as Data Products
- Data Products available to you from all domains
- This page only shows Kafka Topics based data products. A full implementation would also show data products from other APIs
"""


manageOutro : String
manageOutro =
    """
Important functions of this tab that are not included in this prototype:
  - Deprecate a data product, such that only existing consumers can continue to use it
  - Issue a warning if you try to unregister a data product being consumed by an app
  - Specify consumer access permission requirements
    """


type alias TableConfigFlags msg =
    { showControls : Bool
    , caption : Maybe (List (Html msg))
    }


tableConfig : TableConfigFlags Msg -> Table.Config Stream Msg
tableConfig { showControls, caption } =
    Table.customConfig
        { toId = streamQualifiedName >> unQualifiedName
        , toMsg = SetDataProductsTableState
        , columns =
            [ Table.stringColumnWithAttributes
                "Name"
                [ UIKit.width_1_10 ]
                getStreamName
            , Table.stringColumnWithAttributes
                "Domain"
                [ UIKit.width_1_10 ]
                (getStreamDomain >> Maybe.map unDomain >> withDefault "-")
            , Table.stringColumnWithAttributes
                "Description"
                [ UIKit.width_2_10 ]
                (getStreamDescription >> withDefault "-")
            , Table.stringColumnWithAttributes
                "Owner"
                [ UIKit.width_1_10 ]
                (getStreamOwner >> withDefault "-")
            , Table.stringColumnWithAttributes
                "Quality"
                [ UIKit.width_1_10 ]
                (getStreamQuality >> maybe "-" showProductQuality)
            , Table.stringColumnWithAttributes
                "SLA"
                [ UIKit.width_1_10 ]
                (getStreamSLA >> maybe "-" showProductSla)
            , Table.veryCustomColumn
                { name = "Action"
                , viewData =
                    \dataProduct ->
                        Table.HtmlDetails [ UIKit.width_2_10 ]
                            (if showControls then
                                [ publishButton dataProduct ]

                             else
                                [ span [] [] ]
                            )
                , sorter =
                    Table.unsortable
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
                , caption =
                    case caption of
                        Nothing ->
                            Nothing

                        Just contents ->
                            Just
                                (Table.HtmlDetails []
                                    contents
                                )
                , thead = Table.infoThead columnTooltips
            }
        }


columnTooltips : String -> Maybe String
columnTooltips name =
    case name of
        "Name" ->
            Just "The name may be a simple human-readable name, but can also be a full structured URI for explicitness"

        "Domain" ->
            Just "The domain that the data product belongs to, typically that of the producer service"

        "Description" ->
            Just "Plain-text, human-readable description of what this data product is for. Used primarily for discovery and search"

        "Owner" ->
            Just "The team responsible for producing, evolving, and maintaining the quality and SLAs of the data product"

        "Quality" ->
            Just "Represents the level of production readiness. An organization may impose quality requirements based on data management and risk needs"

        "SLA" ->
            Just "Minimum level of service to expect in case of outages. Estimates a time to recovery based on a tier system"

        "Action" ->
            Just "Allows you to publish or remove the data product from the data mesh. Note that a full-featured product may also include a 'deprecate' button, to enable migration off of deprecated data products"

        _ ->
            Nothing


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

        hasValidationError err =
            case validationResult of
                Ok _ ->
                    False

                Err errs ->
                    List.member err errs
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
                                        ++ (if hasValidationError RestrictedOwner then
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
                        , hr [] []
                        , div [ UIKit.formControlsText ]
                            [ input
                                ([ type_ "checkbox"
                                 , id "terms_acknowledged"
                                 , UIKit.checkbox
                                 , checked model.termsAcknowledged
                                 , onCheck (PublishFormMsg << PublishFormSetTermsAcknowledged)
                                 ]
                                    ++ (if hasValidationError TermsNotAcknowledged then
                                            [ UIKit.formDanger ]

                                        else
                                            []
                                       )
                                )
                                []
                            , label
                                [ for "terms_acknowledged"
                                ]
                                [ text " "
                                , text "I acknowledge that by publishing this Data Product, I agree to the terms outlined in my SLA."
                                ]
                            ]
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


getStreamDomain : Stream -> Maybe Domain
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

        StreamTopic _ ->
            Nothing


formatValidationError : PublishFormError -> Html msg
formatValidationError error =
    case error of
        RestrictedOwner ->
            text "That owner is reserved. Please choose another."

        TermsNotAcknowledged ->
            text "Please acknowledge the SLA requirements."
