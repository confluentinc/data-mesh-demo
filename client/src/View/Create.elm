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
import View.Tooltips exposing (tooltip)


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
    """## Using Data Products for Business Needs
Once you have identified which data products you need for your business use-case, you can then create the application.

In this page, we have several sample business use-cases that outline the consumption and usage of our pre-published data products.
    """


useCasesView : Maybe UseCaseName -> Dict UseCaseName UseCase -> Html Msg
useCasesView activeUseCaseKey useCases =
    div [ class "create-use-cases" ]
        [ h2 [] [ text "Sample Business Use-Cases"
        , tooltip "There are many ways to use and create data products. These business use-cases illustrate consuming both data products and event streams that are internal to the domain"
        ]
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
        [ h2 [] [ text "Application Information"
        , tooltip "These sample applications all use ksqlDB for the sake of the prototype. You are free to use any technology to consume and use these data products, from monolithic consumers, to event-driven microservices, to batch-based jobs. You can then in turn emit new data to its own event stream, with may also become its own data product"]
        , case mUseCase of
            Nothing ->
                i [] [ text "Select a use case from the table on the left." ]

            Just useCase ->
                table
                    [ UIKit.table
                    , UIKit.tableDivider
                    , class "table-horizontal"
                    ]
                    [ tbody []
                        (List.map
                            (\( title, content ) ->
                                tr []
                                    [ th [] [ text title ]
                                    , td [] [ content ]
                                    ]
                            )
                            [ ( "Title", text useCase.title )
                            , ( "Description", text useCase.description )
                            , ( "Name", code [] [ text (unUseCaseName useCase.name) ] )
                            , ( "Inputs", code [] [ text useCase.inputs ] )
                            , ( "Output Topic"
                              , code [] [ text useCase.outputTopic ]
                              )
                            , ( "ksqlDB Statement"
                              , pre [ style "max-height" "300px" ]
                                    [ code [] [ text useCase.ksqlDbCommand ] ]
                              )
                            ]
                        )
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
                    , UIKit.marginBottom
                    , onClick (ExecuteUseCase useCase.name)
                    ]
                    [ text "Execute this ksqlDB statement"
                    ]
        ]
