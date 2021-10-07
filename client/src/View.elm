module View exposing (view)

import Array exposing (Array)
import Browser exposing (..)
import Dialog.Common as Dialog
import Dialog.UIKit as Dialog
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Encode as Encode
import Route exposing (routeToString)
import Stomp exposing (AuditLogMsg)
import Types exposing (..)
import UIKit
import Url exposing (..)
import View.Create
import View.Discover
import View.Manage


view : Model -> Document Msg
view model =
    { title = "Data Mesh"
    , body =
        [ headerView model.flags.staticImages.logoPath
        , mainView model
        , footerView model.auditLogModel
        , Dialog.view
            (Maybe.map (View.Manage.publishDialog model.publishFormResult) model.publishForm)
        , Dialog.view
            (Maybe.map (screenshotDialog model.flags.staticImages) model.activeScreenshot)
        ]
    }


headerView : String -> Html msg
headerView logoPath =
    header []
        [ div [ UIKit.container ]
            [ img
                [ class "logo"
                , src logoPath
                ]
                []
            , h1 [] [ text "Confluent" ]
            ]
        ]


mainView : Model -> Html Msg
mainView model =
    div [ class "main" ]
        [ div [ UIKit.container ]
            [ ul
                [ UIKit.tab ]
                (List.map (tabView model.activeView)
                    [ ( Discover Nothing, "Explore Data Mesh" )
                    , ( Create Nothing, "Derive Data Products" )
                    , ( Manage, "Manage & Publish" )
                    ]
                )
            , case model.activeView of
                Discover mQualifiedName ->
                    View.Discover.view mQualifiedName model

                Create mName ->
                    View.Create.view mName model

                Manage ->
                    View.Manage.view model

                NotFound ->
                    notFoundView model
            ]
        ]


tabView : View -> ( View, String ) -> Html Msg
tabView activeView ( tab, label ) =
    li [ classList [ ( "uk-active", isSameTab activeView tab ) ] ]
        [ a [ href (routeToString tab) ] [ text label ] ]



notFoundView : Model -> Html msg
notFoundView model =
    h2 [] [ text "Not Found" ]


footerView : AuditLogModel -> Html Msg
footerView auditLogModel =
    footer
        ([ class "audit-log" ]
            ++ (if auditLogModel.minimised then
                    [ class "audit-log-minimised" ]

                else
                    []
               )
        )
        [ button
            [ UIKit.button
            , UIKit.buttonSecondary
            , class "audit-log-switch"
            , onClick ToggleAuditMinimised
            ]
            [ text "Audit Log" ]
        , auditLogMsgsView auditLogModel.messages
        ]


auditLogMsgsView : Array (Result String AuditLogMsg) -> Html msg
auditLogMsgsView messages =
    ul []
        (messages
            |> Array.toList
            |> List.map auditLogMsgView
        )


auditLogMsgView : Result String AuditLogMsg -> Html msg
auditLogMsgView auditLogMsg =
    li [] <|
        case auditLogMsg of
            Err err ->
                [ text err ]

            Ok result ->
                [ text result.message
                , pre []
                    (List.intersperse
                        (text "\n")
                        (List.map text result.commands)
                    )
                ]


screenshotDialog : StaticImages -> ScreenshotTarget -> Dialog.Config Msg
screenshotDialog staticImages screenshotTarget =
    let
        ( title, imagePath ) =
            case screenshotTarget of
                ExportScreenshot ->
                    ( "Export - Preview", staticImages.exportScreenshotPath )

                SchemaScreenshot ->
                    ( "Schema Detail - Preview", staticImages.schemaScreenshotPath )

                TopicScreenshot ->
                    ( "Topic Detail - Preview", staticImages.topicScreenshotPath )

                LineageScreenshot ->
                    ( "Data Lineage - Preview", staticImages.lineageScreenshotPath )
    in
    { closeMessage = Just ClearScreenshot
    , containerClass = Just "screenshot-dialog"
    , header = Just (h2 [] [ text title ])
    , body =
        Just
            (div []
                [ img [ src imagePath ]
                    []
                ]
            )
    , footer =
        Just
            (button
                [ UIKit.button
                , UIKit.buttonPrimary
                , onClick ClearScreenshot
                ]
                [ text "Close" ]
            )
    }
