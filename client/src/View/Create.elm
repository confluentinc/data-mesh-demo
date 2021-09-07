module View.Create exposing (view)

import Browser exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Route exposing (routeToString)
import Table exposing (defaultCustomizations)
import Types exposing (..)
import UIKit
import Url exposing (..)


view : Model -> Html Msg
view model =
    div [ class "create-pane" ]
        [ mainView
        , useCasesView model.createOption
        , useCasesDetail model.createOption
        , publishView
        ]


mainView : Html msg
mainView =
    div [ class "create-main" ]
        [ h2 [] [ text "Data Product Creation" ]
        , p [] [ text "There are many ways to create a data product. An application may create a data product from user inputs, from REST calls, event streams, other sources, or a combination of inputs. The application code and frameworks that can be used to build data products varies just as widely, from monoliths, to microservices, to batch and streaming jobs." ]
        , p [] [ text "In this demo, we’re showcasing creating new data products using existing data products in the form of event streams." ]
        , p [] [ text "The following example shows the creation of a new ksqlDB application, output Kafka topic, and event schema. The application joins the pageviews and users together, enriching the output into a new Kafka topic." ]
        , p [] [ text "Click the button to go to Confluent Cloud, where this query will be pre-populated. Create the application and return to this screen." ]
        ]


useCasesView : CreateOption -> Html Msg
useCasesView activeOption =
    div [ class "create-use-cases" ]
        [ h2 [] [ text "Sample Business Use-Cases" ]
        , table
            [ UIKit.table
            , UIKit.tableDivider
            , UIKit.tableStriped
            , UIKit.tableSmall
            ]
            [ thead []
                [ tr [] [ text "Options" ]
                , tbody []
                    (List.map
                        (\option ->
                            tr
                                ([ onClick (HighlightCreateOption option) ]
                                    ++ (if activeOption == option then
                                            [ UIKit.active ]

                                        else
                                            []
                                       )
                                )
                                [ td [] (createOptionCopy option) ]
                        )
                        [ Enrich
                        , Filter
                        , Aggregate
                        ]
                    )
                ]
            ]
        ]


createOptionCopy : CreateOption -> List (Html msg)
createOptionCopy createOption =
    case createOption of
        Enrich ->
            [ text "Option 1: Enrich the pageviews" ]

        Filter ->
            [ text "Option 2: Filter out specific pageviews" ]

        Aggregate ->
            [ text "Option 3: Aggregate to find the most popular pages" ]


useCasesDetail : CreateOption -> Html msg
useCasesDetail createOption =
    div [ class "create-use-detail" ]
        [ h2 [] [ text "Application Information" ]
        , table
            [ UIKit.table
            , UIKit.tableDivider
            , UIKit.tableStriped
            , UIKit.tableSmall
            ]
            [ tbody []
                (List.map
                    (\( title, content ) ->
                        tr
                            []
                            [ th [] [ text title ]
                            , td [] [ pre [] [ text content ] ]
                            ]
                    )
                    [ ( "Name", "pageviews" )
                    , ( "Data Product Inputs", "pageviews, users" )
                    , ( "Query"
                      , case createOption of
                            Enrich ->
                                enrichQuery

                            Filter ->
                                "TODO"

                            Aggregate ->
                                "TODO"
                      )
                    , ( "Output Topic"
                      , case createOption of
                            Enrich ->
                                "enriched_pageviews"

                            Filter ->
                                "filtered_pageviews"

                            Aggregate ->
                                "popular_pages"
                      )
                    ]
                )
            ]
        , a
            [ UIKit.button
            , UIKit.buttonPrimary
            ]
            [ text "Run this ksqlDB app" ]
        ]


publishView : Html msg
publishView =
    div [ class "create-publish" ]
        [ p [] [ text "Now you can publish this as a data product!" ]
        , a
            [ UIKit.button
            , UIKit.buttonPrimary
            , href (routeToString Manage)
            ]
            [ text "Publish as data product" ]
        ]


enrichQuery : String
enrichQuery =
    """CREATE TABLE PAGEVIEWS_ENRICHED AS
SELECT U.USERID, U.REGISTERTIME, V.VIEWTIME, V.PAGEID
FROM USERS U
INNER JOIN PAGEVIEWS V
ON U.USERID = V.USERID
EMIT CHANGES;"""
