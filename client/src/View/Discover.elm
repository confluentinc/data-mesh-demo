module View.Discover exposing (view)

import GenericDict as Dict
import Html exposing (..)
import Html.Attributes exposing (class, disabled, href, rows, target, type_, value, wrap)
import Html.Events exposing (onClick)
import Json.Extras as Json
import Markdown
import RemoteData exposing (RemoteData(..))
import Table exposing (defaultCustomizations)
import Table.Extras as Table
import Types exposing (..)
import UIKit
import Url exposing (Url)
import View.Common exposing (..)
import View.Icons exposing (Icon(..), icon)


view : Maybe QualifiedName -> Model -> Html Msg
view activeStreamKey model =
    let
        activeStream =
            Maybe.map2
                (Dict.get unQualifiedName)
                activeStreamKey
                (RemoteData.toMaybe model.streams)
                |> Maybe.withDefault Nothing
    in
    div [ class "discover-pane" ]
        [ div [ class "discover-main" ]
            [ h2 []
                 (case (model.actuatorInfo) of
                     ( Success actuatorInfo) ->
                        [ text ("Data Products available in the " ++ actuatorInfo.domain ++ " domain") ]
                     _ -> []
                 )
            , webDataView
                (Table.view
                    (tableConfig activeStreamKey)
                    model.dataProductsTableState
                )
                (RemoteData.map
                    (Dict.values >> filterDataProducts)
                    model.streams
                )
            ]
        , div [ class "discover-detail" ]
            [ h2 [] [ text "Data Products Detail" ]
            , streamDetailView
                (RemoteData.toMaybe model.actuatorInfo)
                activeStream
            ]
        , div [ class "discover-copy" ]
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
            , Markdown.toHtml [] discoverCopy
            ]
        ]


discoverCopy : String
discoverCopy =
    """
Discover the data products that are relevant to your domain.

Data Product information contains all the relevant info about this
product. You can view schemas, ownership, description, and lineage
information.

You can also export the data product to your own external data store
for use by individual applications.
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
                            ++ [ onClick
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


streamDetailView : Maybe ActuatorInfo -> Maybe Stream -> Html Msg
streamDetailView mActuatorInfo mStream =
    case mStream of
        Nothing ->
            i [] [ text "Select a product from the table on the left." ]

        Just (StreamDataProduct dataProduct) ->
            div []
                [ form [ UIKit.formHorizontal ]
                    [ disabledFormInput "Name" dataProduct.name
                    , disabledFormInput "Domain" dataProduct.domain
                    , disabledFormInput "Description" dataProduct.description
                    , disabledFormInput "Owner" dataProduct.owner
                    , disabledFormInput "Quality" (showProductQuality dataProduct.quality)
                    , disabledFormInput "SLA" (showProductSla dataProduct.sla)
                    , div []
                        [ label [ UIKit.formLabel ] [ text "Schema" ]
                        , div [ UIKit.formControls ]
                            [ textarea
                                [ UIKit.textarea
                                , class "schema"
                                , value (Json.prettyPrintIfPossible dataProduct.schema.schema)
                                , disabled True
                                , rows 10
                                , wrap "soft"
                                ]
                                []
                            ]
                        ]
                    ]
                , case mActuatorInfo of
                    Just actuatorInfo ->
                        div [ UIKit.margin, UIKit.width_1_1 ]
                            (List.intersperse (text " ")
                                (List.map (linkButton actuatorInfo.hostedMode)
                                    [ ( "Topic Detail", dataProduct.urls.portUrl, TopicScreenshot )
                                    , ( "Schema Detail", dataProduct.urls.schemaUrl, SchemaScreenshot )
                                    , ( "Data Lineage", dataProduct.urls.lineageUrl, LineageScreenshot )
                                    , ( "Export", dataProduct.urls.exportUrl, ExportScreenshot )
                                    ]
                                )
                            )

                    Nothing ->
                        span [] []
                ]

        Just (StreamTopic topic) ->
            div []
                [ form [ UIKit.formHorizontal ]
                    [ disabledFormInput "Name" topic.name
                    ]
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


disabledFormInput : String -> String -> Html msg
disabledFormInput inputLabel inputValue =
    div []
        [ label [ UIKit.formLabel ] [ text inputLabel ]
        , div [ UIKit.formControls ]
            [ input
                [ type_ "text"
                , UIKit.input
                , value inputValue
                , disabled True
                ]
                []
            ]
        ]
