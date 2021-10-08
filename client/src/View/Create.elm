module View.Create exposing (view)

import Browser exposing (..)
import GenericDict as Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Markdown
import Route exposing (routeToString)
import Types exposing (..)
import UIKit
import Url exposing (..)
import View.Common exposing (webDataView)
import View.Icons exposing (Icon(..), icon)


view : Maybe String -> Model -> Html Msg
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
                        Maybe.andThen (\k -> Dict.get identity k useCases) activeUseCaseKey
                in
                useCasesDetail activeUseCase
            )
            model.useCases
        , publishView
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
                [ tr [] [ th [] [ text "Options" ] ] ]
            , tbody []
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
                                    [ text (String.fromInt (index + 1) ++ ": " ++ useCase.description) ]
                                ]
                        )
                )
            ]
        ]


useCasesDetail : Maybe UseCase -> Html msg
useCasesDetail mUseCase =
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
                        , target "_blank"
                        , href (Url.toString useCase.ksqlDbLaunchUrl)
                        ]
                        [ text "Run this ksqlDB statement"
                        , icon ExternalLink
                        ]
                    ]
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
