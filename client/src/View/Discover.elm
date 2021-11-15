module View.Discover exposing (deleteConfirmationDialog, view)

import Dialog.Common as Dialog
import GenericDict as Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (class, disabled, href, target, type_, value)
import Html.Events exposing (onClick)
import Json.Extras as Json
import Markdown
import RemoteData exposing (RemoteData(..), WebData)
import Table exposing (defaultCustomizations)
import Table.Extras as Table
import Types exposing (..)
import UIKit
import Url exposing (Url)
import View.Common exposing (..)
import View.Icons exposing (Icon(..), icon)
import View.Tooltips exposing (tooltip)


view : Maybe QualifiedName -> Model -> Html Msg
view activeStreamKey model =
    webDataView
        (\streams ->
            let
                activeStream =
                    activeStreamKey
                        |> Maybe.map
                            (\key -> Dict.get unQualifiedName key streams)
                        |> Maybe.withDefault Nothing
            in
            div [ class "discover-pane" ]
                [ header []
                    [ Markdown.toHtml [] discoveryIntro ]
                , div [ class "discover-main" ]
                    [ h2 []
                        [ text
                            (case model.actuatorInfo of
                                Success info ->
                                    "Data Products available for the Analytics Domain"

                                _ ->
                                    "Data Products available"
                            )
                        , tooltip "Discover the data products that are publicly visible to your domain"
                        ]
                    , Table.view
                        (tableConfig activeStreamKey)
                        model.dataProductsTableState
                        (streams
                            |> Dict.values
                            |> filterDataProducts
                        )
                    ]
                , div [ class "discover-detail" ]
                    [ h2 []
                        [ text "Data Products Detail"
                        , tooltip "Contains all the relevant info about your data products. This information is intended to help you identify the data products relevant to your business use-case"
                        ]
                    , streamDetailView
                        (RemoteData.toMaybe model.actuatorInfo)
                        activeStream
                    ]
                , div [ class "discover-search" ]
                    [ p []
                        (case ( model.actuatorInfo, Url.fromString "https://confluent.cloud/search" ) of
                            ( Success actuatorInfo, Just url ) ->
                                [ linkButton actuatorInfo.hostedMode
                                    ( "Advanced Search"
                                    , url
                                    , SearchScreenshot
                                    )
                                ]

                            _ ->
                                []
                        )
                    ]
                , footer []
                    [ Markdown.toHtml [] discoveryOutro ]
                ]
        )
        model.streams


discoveryIntro : String
discoveryIntro =
    """
## Discover data products you can consume

*Role: Prospective Consumer*

This tab lets you explore the data products available to you. Data products are published from multiple domains, and finding the ones you need is a necessary step for building a new application. In this tab, you can:
  - Explore data products
  - View descriptions, schemas, and other details
  - Identify the data products needed for your application

"""


discoveryOutro : String
discoveryOutro =
    """
Important functions for consumers that are not included in this prototype:
  - Register your to-be-built application as a consumer of the data product
  - Request access to sensitive data products, such as those containing PII
  \t- The request will need to be approved by the appropriate team
  - Communicate with the producers and consumers of the data product
    """


filterDataProducts : List Stream -> List DataProduct
filterDataProducts =
    List.filterMap
        (\stream ->
            case stream of
                StreamDataProduct dataProduct ->
                    Just dataProduct

                StreamTopic _ ->
                    Nothing
        )


tableConfig : Maybe QualifiedName -> Table.Config DataProduct Msg
tableConfig activeStreamKey =
    Table.customConfig
        { toId = .qualifiedName >> unQualifiedName
        , toMsg = SetDataProductsTableState
        , columns =
            [ Table.stringColumn "Name" .name
            , Table.stringColumnWithAttributes
                "Description"
                [ class "description" ]
                .description
            , Table.stringColumn "Owner" .owner
            ]
        , customizations =
            { defaultCustomizations
                | tableAttrs =
                    [ UIKit.table
                    , UIKit.tableDivider
                    , UIKit.tableStriped
                    , UIKit.tableSmall
                    ]
                , rowAttrs =
                    \dataProduct ->
                        let
                            isActive =
                                Just dataProduct.qualifiedName == activeStreamKey
                        in
                        (if isActive then
                            [ UIKit.active ]

                         else
                            []
                        )
                            ++ [ selectable
                               , onClick
                                    (ChangeView
                                        (Discover
                                            (if isActive then
                                                Nothing

                                             else
                                                Just dataProduct.qualifiedName
                                            )
                                        )
                                    )
                               ]
            }
        }


disabledForm : List (Html msg) -> Html msg
disabledForm children =
    form [ UIKit.formHorizontal ]
        [ fieldset
            [ UIKit.fieldset
            , disabled True
            ]
            children
        ]


streamDetailView : Maybe ActuatorInfo -> Maybe Stream -> Html Msg
streamDetailView mActuatorInfo mStream =
    case mStream of
        Nothing ->
            i [] [ text "Select a product from the table on the left." ]

        Just (StreamDataProduct dataProduct) ->
            div []
                [ table
                    [ UIKit.table
                    , UIKit.tableDivider
                    , class "table-horizontal"
                    ]
                    (List.map
                        (\( title, content ) ->
                            tr []
                                [ th [] [ text title ]
                                , td [] [ content ]
                                ]
                        )
                        [ ( "Name", code [] [ text dataProduct.name ] )
                        , ( "Domain", code [] [ text (unDomain dataProduct.domain) ] )
                        , ( "Owner", code [] [ text dataProduct.owner ] )
                        , ( "Quality", text (showProductQuality dataProduct.quality) )
                        , ( "SLA", text (showProductSla dataProduct.sla) )
                        , ( "Schema"
                          , pre []
                                [ code []
                                    [ text (Json.prettyPrintIfPossible dataProduct.schema.schema)
                                    ]
                                ]
                          )
                        ]
                    )
                , case mActuatorInfo of
                    Just actuatorInfo ->
                        div [ UIKit.margin, UIKit.width_1_1 ]
                            (List.intersperse (text " ")
                                (List.map (linkButton actuatorInfo.hostedMode)
                                    [ ( "Topic Detail", dataProduct.urls.portUrl, TopicScreenshot )
                                    , ( "Data Lineage", dataProduct.urls.lineageUrl, LineageScreenshot )
                                    , ( "Export", dataProduct.urls.exportUrl, ExportScreenshot )
                                    ]
                                )
                            )

                    Nothing ->
                        span [] []
                ]

        Just (StreamTopic topic) ->
            disabledForm
                [ stringInput "Name" topic.name
                ]


linkButton : HostedMode -> ( String, Url, ScreenshotTarget ) -> Html Msg
linkButton hostedMode ( description, url, screenshotTarget ) =
    let
        sharedAttributes =
            [ UIKit.button
            , UIKit.buttonPrimary
            , UIKit.buttonSmall
            , href (Url.toString url)
            , target "_blank"
            ]
    in
    case hostedMode of
        Hosted ->
            button
                (sharedAttributes
                    ++ [ onClick (ShowScreenshot screenshotTarget) ]
                )
                [ text description ]

        Local ->
            a
                (sharedAttributes
                    ++ [ href (Url.toString url)
                       , target "_blank"
                       ]
                )
                [ text description
                , icon ExternalLink
                ]


stringInput : String -> String -> Html msg
stringInput inputLabel inputValue =
    div []
        [ label [ UIKit.formLabel ] [ text inputLabel ]
        , div [ UIKit.formControls ]
            [ input
                [ type_ "text"
                , UIKit.input
                , value inputValue
                ]
                []
            ]
        ]


deleteConfirmationDialog : DataProduct -> Dialog.Config Msg
deleteConfirmationDialog dataProduct =
    { closeMessage = Just AbandonDeleteDataProduct
    , containerClass = Nothing
    , header =
        Just
            (h2 [ UIKit.modalTitle ]
                [ text "Are you sure?" ]
            )
    , body =
        Just
            (div []
                [ p []
                    [ text "Are you sure you want to remove "
                    , code [] [ text dataProduct.name ]
                    , text " from the data mesh?"
                    ]
                , p []
                    [ text "Ensure that all consumers have been informed of the removal and have migrated accordingly." ]
                ]
            )
    , footer =
        Just
            (div []
                [ button
                    [ UIKit.button
                    , UIKit.buttonDefault
                    , onClick AbandonDeleteDataProduct
                    ]
                    [ text "Cancel" ]
                , button
                    [ UIKit.button
                    , UIKit.buttonDanger
                    , onClick (ConfirmDeleteDataProduct dataProduct.qualifiedName)
                    ]
                    [ text "Confirm" ]
                ]
            )
    }
