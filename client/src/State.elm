module State exposing (init, onUrlChange, onUrlRequest, subscriptions, update)

import Array
import Browser exposing (..)
import Browser.Navigation as Nav
import GenericDict as Dict
import Html exposing (..)
import Monocle.Compose exposing (lensWithLens)
import Monocle.Lens exposing (modify)
import Optics
import RemoteData exposing (RemoteData(..))
import RemoteData.Extra exposing (mapOnSuccess)
import Rest
import Route exposing (routeParser)
import Scrolling exposing (scrollToBottom)
import Stomp
import Table
import Types exposing (..)
import Url exposing (..)
import View


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        ( stompSession, stompCmds ) =
            Stomp.init
    in
    ( { navKey = navKey
      , stompSession = stompSession
      , auditLogModel =
            { minimised = True
            , messages = Array.empty
            }
      , flags = flags
      , actuatorInfo = Loading
      , activeView = routeParser url
      , activeScreenshot = Nothing
      , dataProductsTableState = Table.initialSort "name"
      , streams = Loading
      , useCases = Loading
      , publishForm = Nothing
      , publishFormResult = NotAsked
      , deleteConfirmation = Nothing
      , deleteResult = NotAsked
      , executeUseCaseResult = NotAsked
      }
    , Cmd.batch
        [ Rest.getStreams
        , Rest.getUseCases
        , Rest.getActuatorInfo
        , Cmd.map StompMsg stompCmds
        ]
    )


onUrlChange : Url -> Msg
onUrlChange _ =
    NoOp


onUrlRequest : UrlRequest -> Msg
onUrlRequest =
    ChangeUrl


subscriptions : Model -> Sub Msg
subscriptions model =
    Stomp.subscriptions model.stompSession
        |> Sub.map StompMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ChangeUrl urlRequest ->
            case urlRequest of
                Internal url ->
                    update (ChangeView (routeParser url)) model

                External url ->
                    ( model
                    , Nav.load url
                    )

        ChangeView view ->
            ( { model
                | activeView = view
                , deleteResult = NotAsked
                , executeUseCaseResult = NotAsked
              }
            , Nav.pushUrl model.navKey (Route.routeToString view)
            )

        ToggleAuditMinimised ->
            let
                target =
                    lensWithLens Optics.minimised Optics.auditLogModel
            in
            ( modify target not model
            , Cmd.none
            )

        ShowScreenshot image ->
            ( { model | activeScreenshot = Just image }
            , Cmd.none
            )

        ClearScreenshot ->
            ( { model | activeScreenshot = Nothing }
            , Cmd.none
            )

        StompMsg subMsg ->
            let
                ( output, ( subModel, subCmd ) ) =
                    Stomp.update subMsg model.stompSession

                updateMessages =
                    case output of
                        Nothing ->
                            identity

                        Just (Stomp.TransportError err) ->
                            -- Despite having the option, We won't give transport error messages special treatment.
                            Array.push (Err err)

                        Just (Stomp.GotMessage auditLogMsg) ->
                            Array.push auditLogMsg
            in
            ( model
                |> Optics.stompSession.set subModel
                |> modify Optics.auditLogMessages updateMessages
            , Cmd.batch
                [ Cmd.map StompMsg subCmd
                , scrollToBottom View.auditLogMsgsId
                ]
            )

        SetDataProductsTableState newTableState ->
            ( { model | dataProductsTableState = newTableState }
            , Cmd.none
            )

        GotStreams newStreams ->
            ( { model | streams = newStreams }
            , Cmd.none
            )

        GotUseCases newUseCases ->
            ( { model | useCases = newUseCases }
            , Cmd.none
            )

        GotActuatorInfo newActuatorInfo ->
            ( { model | actuatorInfo = newActuatorInfo }
            , Cmd.none
            )

        StartPublishDialog qualifiedName ->
            let
                topic : Maybe Topic
                topic =
                    (Optics.streamTopic qualifiedName).getOption model

                dialog : Maybe PublishForm
                dialog =
                    case topic of
                        Just t ->
                            Just
                                { topic = t
                                , owner = ""
                                , description =
                                    topic
                                        |> Maybe.map generateDescription
                                        |> Maybe.withDefault ""
                                , quality = Raw
                                , sla = Tier3
                                , termsAcknowledged = False
                                }

                        Nothing ->
                            Nothing
            in
            ( { model
                | publishForm = dialog
                , publishFormResult = NotAsked
              }
            , Cmd.none
            )

        AbandonPublishDialog ->
            ( { model
                | publishForm = Nothing
                , publishFormResult = NotAsked
              }
            , Cmd.none
            )

        PublishFormMsg subMsg ->
            case model.publishForm of
                Nothing ->
                    ( model, Cmd.none )

                Just publishForm ->
                    let
                        ( subModel, subCmd ) =
                            updatePublishForm subMsg publishForm
                    in
                    ( { model | publishForm = Just subModel }
                    , subCmd
                    )

        PublishDataProduct publishForm ->
            ( { model
                | publishFormResult = Loading
              }
            , Rest.publishDataProduct publishForm
            )

        DataProductPublished (Success newDataProduct) ->
            ( { model
                | publishForm = Nothing
                , publishFormResult = NotAsked
                , streams =
                    RemoteData.map
                        (Dict.insert unQualifiedName
                            newDataProduct.qualifiedName
                            (StreamDataProduct newDataProduct)
                        )
                        model.streams
              }
            , Cmd.none
            )

        DataProductPublished result ->
            ( { model
                | publishFormResult = result
              }
            , Cmd.none
            )

        DeleteDataProduct qualifiedName ->
            case
                (Optics.streamDataProduct qualifiedName).getOption model
            of
                Just dataProduct ->
                    ( { model | deleteConfirmation = Just dataProduct }
                    , Cmd.none
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )

        AbandonDeleteDataProduct ->
            ( { model
                | deleteConfirmation = Nothing
              }
            , Cmd.none
            )

        ConfirmDeleteDataProduct qualifiedName ->
            ( { model
                | deleteConfirmation = Nothing
                , deleteResult = Loading
              }
            , Rest.deleteDataProduct qualifiedName
            )

        DataProductDeleted result ->
            ( { model
                | deleteResult = result
                , streams =
                    mapOnSuccess
                        (\key ->
                            Dict.update unQualifiedName
                                key
                                (Maybe.map unpublishStream)
                        )
                        result
                        model.streams
              }
            , Cmd.none
            )

        ExecuteUseCase useCaseName ->
            ( { model | executeUseCaseResult = Loading }
            , Rest.executeUseCase useCaseName
            )

        UseCaseExecuted result ->
            ( { model
                | executeUseCaseResult = result
              }
            , case result of
                Success _ ->
                    Rest.getStreams

                _ ->
                    Cmd.none
            )


updatePublishForm : PublishFormMsg -> PublishForm -> ( PublishForm, Cmd msg )
updatePublishForm msg model =
    case msg of
        PublishFormSetOwner newOwner ->
            ( { model | owner = newOwner }, Cmd.none )

        PublishFormSetDescription newDescription ->
            ( { model | description = newDescription }, Cmd.none )

        PublishFormSetQuality newQuality ->
            ( { model | quality = newQuality }, Cmd.none )

        PublishFormSetSla newSla ->
            ( { model | sla = newSla }, Cmd.none )

        PublishFormSetTermsAcknowledged newTermsAcknowledged ->
            ( { model | termsAcknowledged = newTermsAcknowledged }, Cmd.none )
