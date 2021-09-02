module View.Manage exposing (view)

import Browser exposing (..)
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
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
            (Table.view tableConfig model.dataProductsTableState << Dict.values)
            model.dataProducts
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
            }
        }
