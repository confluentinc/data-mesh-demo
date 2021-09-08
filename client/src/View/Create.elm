module View.Create exposing (view)

import Browser exposing (..)
import GenericDict as Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Route exposing (routeToString)
import Table exposing (defaultCustomizations)
import Types exposing (..)
import UIKit
import Url exposing (..)
import View.Common exposing (webDataView)


view : Model -> Html Msg
view model =
    div [ class "create-pane" ]
        [ mainView
        , webDataView
            (useCasesView model.activeUseCaseKey)
            model.useCases
        , webDataView
            (\useCases ->
                let
                    activeUseCase =
                        Maybe.andThen (\k -> Dict.get identity k useCases) model.activeUseCaseKey
                in
                case activeUseCase of
                    Nothing ->
                        text ""

                    Just active ->
                        useCasesDetail active
            )
            model.useCases
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


useCasesView : Maybe String -> Dict String UseCase -> Html Msg
useCasesView activeUseCaseKey useCases =
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
                    (useCases
                        |> Dict.values
                        |> List.map
                            (\useCase ->
                                tr
                                    ([ onClick (SelectUseCase useCase.name) ]
                                        ++ (if activeUseCaseKey == Just useCase.name then
                                                [ UIKit.active ]

                                            else
                                                []
                                           )
                                    )
                                    [ td [] [ text useCase.description ] ]
                            )
                    )
                ]
            ]
        ]


useCasesDetail : UseCase -> Html msg
useCasesDetail useCase =
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
                    [ ( "Name", useCase.name )
                    , ( "Data Product Inputs", useCase.inputs )
                    , ( "Query"
                      , useCase.ksqlDbCommand
                      )
                    , ( "Output Topic"
                      , useCase.outputTopic
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
