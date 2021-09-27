module View.Discover exposing (view)

import Browser exposing (..)
import GenericDict as Dict
import Html exposing (..)
import Html.Attributes exposing (class, disabled, href, rows, target, type_, value, wrap)
import Html.Events exposing (onClick)
import Json.Extras as Json
import RemoteData exposing (RemoteData(..))
import Rest
import Route exposing (routeToString)
import Table exposing (defaultCustomizations)
import Types exposing (..)
import UIKit
import Url exposing (Url)
import View.Common exposing (..)


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
            [ h2 [] [ text "Data Products" ]
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
            [ h2 [] [ text "Data Products Information" ]
            , streamDetailView activeStream
            ]
        , div [ class "discover-copy" ]
            [ p []
                [ a
                    [ UIKit.button
                    , UIKit.buttonPrimary
                    , href "https://confluent.cloud/search"
                    , target "_blank"
                    ]
                    [ text "Advanced Search" ]
                ]
            , p [] [ text "Discover the data products that are relevant to your domain." ]
            , p [] [ text "Data Product information contains all the relevant info about this product. You can view schemas, ownership, description, and lineage information." ]
            , p [] [ text "You can also export the data product to your own external data store for use by individual applications." ]
            ]
        ]


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
            , Table.stringColumn "Description" .description
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


streamDetailView : Maybe Stream -> Html Msg
streamDetailView mStream =
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
                , div [ UIKit.margin, UIKit.buttonGroup, class "uk-width-1-1" ]
                    [ linkButton "Topic" dataProduct.urls.portUrl
                    , linkButton "Schema" dataProduct.urls.schemaUrl
                    , linkButton "Lineage" dataProduct.urls.lineageUrl
                    , linkButton "Self-Serve" dataProduct.urls.exportUrl
                    ]
                ]

        Just (StreamTopic topic) ->
            div []
                [ form [ UIKit.formHorizontal ]
                    [ disabledFormInput "Name" topic.name
                    ]
                ]


linkButton : String -> Url -> Html msg
linkButton description url =
    a
        [ UIKit.button
        , UIKit.buttonPrimary
        , href (Url.toString url)
        , target "_blank"
        , class "uk-width-1-4"
        ]
        [ text description ]


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
