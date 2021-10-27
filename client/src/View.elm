module View exposing (auditLogMsgsId, view)

import Array exposing (Array)
import Browser exposing (..)
import Dialog.Common as Dialog
import Dialog.UIKit as Dialog
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Markdown
import Route exposing (routeToString)
import Stomp exposing (AuditLogMsg)
import Types exposing (..)
import UIKit
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
        , Dialog.view
            (Maybe.map View.Discover.deleteConfirmationDialog model.deleteConfirmation)
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
            ]
        ]


mainView : Model -> Html Msg
mainView model =
    div [ class "main" ]
        [ div [ UIKit.container ]
            [ ul
                [ UIKit.tab ]
                (List.map (tabView model.activeView)
                    [ ( Discover Nothing, "1) Explore Data Products" )
                    , ( Create Nothing, "2) Create Apps Using Data Products" )
                    , ( Manage, "3) Publish Data Products" )
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
                    notFoundView
            ]
        ]


tabView : View -> ( View, String ) -> Html Msg
tabView activeView ( tab, label ) =
    li [ classList [ ( "uk-active", isSameTab activeView tab ) ] ]
        [ a [ href (routeToString tab) ] [ text label ] ]


notFoundView : Html msg
notFoundView =
    h2 [] [ text "Not Found" ]


footerView : AuditLogModel -> Html Msg
footerView auditLogModel =
    footer
        (class "audit-log"
            :: (if auditLogModel.minimised then
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


auditLogMsgsId : String
auditLogMsgsId =
    "audit-log-messages"


auditLogMsgsView : Array (Result String AuditLogMsg) -> Html msg
auditLogMsgsView messages =
    ul [ id auditLogMsgsId ]
        (messages
            |> Array.toList
            |> List.map auditLogMsgView
        )


auditLogMsgView : Result String AuditLogMsg -> Html msg
auditLogMsgView auditLogMsg =
    case auditLogMsg of
        Err err ->
            li [ UIKit.textDanger ]
                [ text err ]

        Ok result ->
            li []
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
                    ( "Export", staticImages.exportScreenshotPath )

                SchemaScreenshot ->
                    ( "Schema Detail", staticImages.schemaScreenshotPath )

                TopicScreenshot ->
                    ( "Topic Detail", staticImages.topicScreenshotPath )

                LineageScreenshot ->
                    ( "Data Lineage", staticImages.lineageScreenshotPath )

                SearchScreenshot ->
                    ( "Advanced Search", staticImages.searchScreenshotPath )
    in
    { closeMessage = Just ClearScreenshot
    , containerClass = Just "screenshot-dialog"
    , header = Just (h2 [ UIKit.modalTitle ] [ text title ])
    , body =
        Just
            (div [ UIKit.grid ]
                [ Markdown.toHtml [ UIKit.width_1_3 ]
                    previewCopy
                , img
                    [ UIKit.width_2_3
                    , src imagePath
                    ]
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


previewCopy : String
previewCopy =
    """
### Preview

This is a preview. To get the interactive version you'll can set up
your own local datamesh by following the instructions
[here](https://github.com/confluentinc/data-mesh-demo).
"""
