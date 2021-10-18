module View.Create exposing (view)

import GenericDict as Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Markdown
import RemoteData exposing (RemoteData(..), WebData)
import Route exposing (routeToString)
import Types exposing (..)
import UIKit
import View.Common exposing (errorView, loadingWheel, webDataView)


view : Maybe UseCaseName -> Model -> Html Msg
view activeUseCaseKey model =
    div [ class "create-pane" ]
        [ div [ class "create-main" ]
            [ Markdown.toHtml [] dataProductCreationCopy ]
        , webDataView
            (useCasesView activeUseCaseKey)
            model.useCases
        , webDataView
            (\useCases ->
                let
                    activeUseCase =
                        Maybe.andThen (\k -> Dict.get unUseCaseName k useCases) activeUseCaseKey
                in
                useCasesDetail
                    activeUseCase
                    model.executeUseCaseResult
            )
            model.useCases
        ]


dataProductCreationCopy : String
dataProductCreationCopy =
    """
## Data Product Creation

There are many ways to create a data product. An application may create a data product from user inputs, from REST calls, event streams, other sources, or a combination of inputs. The application code and frameworks that can be used to build data products varies just as widely, from monoliths, to microservices, to batch and streaming jobs.

In this demo, we’re showcasing creating new data products using existing data products in the form of event streams.

The following example shows the creation of a new ksqlDB application, output Kafka topic, and event schema. The application joins the pageviews and users together, enriching the output into a new Kafka topic.

Click the button to go to Confluent Cloud, where this query will be pre-populated. Create the application and return to this screen.
"""


useCasesView : Maybe UseCaseName -> Dict UseCaseName UseCase -> Html Msg
useCasesView activeUseCaseKey useCases =
    div [ class "create-use-cases" ]
        [ h2 [] [ text "Sample Business Use-Cases" ]
        , table
            [ UIKit.table
            , UIKit.tableDivider
            , UIKit.tableStriped
            , UIKit.tableSmall
            ]
            [ tbody []
                (useCases
                    |> Dict.values
                    |> List.indexedMap
                        (\index useCase ->
                            tr
                                (if activeUseCaseKey == Just useCase.name then
                                    [ UIKit.active, onClick (ChangeView (Create Nothing)) ]

                                 else
                                    [ onClick (ChangeView (Create (Just useCase.name))) ]
                                )
                                [ td [ UIKit.button, UIKit.buttonLink ]
                                    [ text (String.fromInt (index + 1) ++ ": " ++ useCase.title) ]
                                ]
                        )
                )
            ]
        ]


useCasesDetail : Maybe UseCase -> WebData UseCaseName -> Html Msg
useCasesDetail mUseCase executeUseCaseResult =
    div [ class "create-use-detail" ]
        [ h2 [] [ text "Application Information" ]
        , case mUseCase of
            Nothing ->
                i [] [ text "Select a use case from the table on the left." ]

            Just useCase ->
                div []
                    [ table
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
                                [ ( "Name", unUseCaseName useCase.name )
                                , ( "Title", useCase.title )
                                , ( "Description", useCase.description )
                                , ( "Inputs", useCase.inputs )
                                , ( "Query"
                                  , useCase.ksqlDbCommand
                                  )
                                , ( "Output Topic"
                                  , useCase.outputTopic
                                  )
                                ]
                            )
                        ]
                    ]
        , case ( mUseCase, executeUseCaseResult ) of
            ( Nothing, _ ) ->
                span [] []

            ( Just _, Loading ) ->
                loadingWheel

            ( Just _, Failure err ) ->
                errorView err

            ( Just _, Success _ ) ->
                div []
                    [ text "Your stream has been created."
                    , text " "
                    , a [ href (routeToString Manage) ] [ text "Go here" ]
                    , text " to review and publish it as a data product."
                    ]

            ( Just useCase, _ ) ->
                button
                    [ UIKit.button
                    , UIKit.buttonPrimary
                    , onClick (ExecuteUseCase useCase.name)
                    ]
                    [ text "Execute this ksqlDB statement"
                    ]
        ]
