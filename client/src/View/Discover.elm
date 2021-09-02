module View.Discover exposing (view)

import Browser exposing (..)
import Dict
import Html exposing (..)
import Html.Attributes exposing (class, disabled, href, target, type_, value)
import Html.Events exposing (onClick)
import Json.Decode as Json
import RemoteData exposing (RemoteData(..))
import Rest
import Route exposing (routeToString)
import Table exposing (defaultCustomizations)
import Types exposing (..)
import UIKit
import Url exposing (Url)
import View.Common exposing (webDataView)
import View.Lorem as Lorem


view : Model -> Html Msg
view model =
    let
        activeDataProduct =
            Maybe.map2
                Dict.get
                model.activeDataProductKey
                (RemoteData.toMaybe model.dataProducts)
                |> Maybe.withDefault Nothing
    in
    div [ class "discover-pane" ]
        [ div [ class "discover-main" ]
            [ h2 [] [ text "Data Products" ]
            , webDataView
                (Table.view tableConfig model.dataProductsTableState << Dict.values)
                model.dataProducts
            ]
        , div [ class "discover-detail" ]
            [ h2 [] [ text "Data Products Information" ]
            , dataProductDetailView activeDataProduct
            ]
        , div [ class "discover-copy" ]
            [ p [] [ text "Discover the data products that are relevant to your domain." ]
            , p [] [ text "Data Product information contains all the relevant info about this product. You can view schemas, ownership, description, and lineage information." ]
            , p [] [ text "You can also export the data product to your own external data store for use by individual applications." ]
            ]
        ]


tableConfig : Table.Config DataProduct Msg
tableConfig =
    Table.customConfig
        { toId = .qualifiedName
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
                , rowAttrs = \dataProduct -> [ onClick (SelectDataProduct dataProduct.qualifiedName) ]
            }
        }


dataProductDetailView : Maybe DataProduct -> Html Msg
dataProductDetailView mDataProduct =
    case mDataProduct of
        Nothing ->
            text ""

        Just dataProduct ->
            div []
                [ form [ UIKit.formHorizontal ]
                    [ disabledFormRow "Name" dataProduct.name
                    , disabledFormRow "Owner" dataProduct.owner
                    , disabledFormRow "Description" dataProduct.description
                    ]
                , div [ UIKit.margin ]
                    [ linkButton "View Lineage" dataProduct.urls.lineageUrl
                    , linkButton "Export to S3" dataProduct.urls.portUrl
                    , linkButton "KafkaConnect" dataProduct.urls.schemaUrl
                    ]
                ]


linkButton : String -> Url -> Html msg
linkButton description url =
    a
        [ UIKit.button
        , UIKit.buttonPrimary
        , href (Url.toString url)
        , target "_blank"
        ]
        [ text description ]


disabledFormRow : String -> String -> Html msg
disabledFormRow inputLabel inputValue =
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
