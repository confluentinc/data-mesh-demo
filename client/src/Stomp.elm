port module Stomp exposing
    ( AuditLogMsg
    , Msg(..)
    , Output(..)
    , decodeAuditLogMsg
    , init
    , subscriptions
    , update
    )

import Json.Decode as Decode exposing (Decoder, field, list, string)
import Json.Encode as Encode
import Stomp.Client as Client exposing (Session)
import Stomp.Message
import Stomp.Proc as Proc
import Stomp.Subscription as Subscription


port socket : Client.Connection msg


port onMessage : Client.OnMessage msg


type Msg
    = Connected
    | Disconnected
    | Error String
    | HeartBeat
    | Message (Result String AuditLogMsg)


type Output
    = TransportError String
    | GotMessage (Result String AuditLogMsg)


auditLogSubscription : String
auditLogSubscription =
    "/topic/audit-log"


init : ( Session Msg, Cmd Msg )
init =
    let
        session =
            Client.init socket
                { onConnected = Connected
                , onDisconnected = Disconnected
                , onError = Error
                , onHeartBeat = HeartBeat
                }
    in
    ( session
    , connect session
    )


subscriptions : Session Msg -> Sub Msg
subscriptions =
    Client.listen onMessage


update :
    Msg
    -> Session Msg
    ->
        ( Maybe Output
        , ( Session Msg, Cmd Msg )
        )
update msg session =
    case msg of
        Connected ->
            ( Nothing
            , subscribe session
            )

        Disconnected ->
            ( Nothing
            , ( session
              , Cmd.none
              )
            )

        HeartBeat ->
            ( Nothing
            , ( session
              , Cmd.none
              )
            )

        Error err ->
            ( Just (TransportError err)
            , ( session
              , Cmd.none
              )
            )

        Message decodedMessage ->
            ( Just (GotMessage decodedMessage)
            , ( session
              , Cmd.none
              )
            )


subscribe : Session Msg -> ( Session Msg, Cmd Msg )
subscribe session =
    Subscription.init auditLogSubscription
        |> Subscription.expectJson Message decodeAuditLogMsg
        |> Client.subscribe session


connect : Session Msg -> Cmd Msg
connect session =
    Client.connect session "" "" "/"


type alias AuditLogMsg =
    { message : String
    , commands : List String
    }


decodeAuditLogMsg : Decoder AuditLogMsg
decodeAuditLogMsg =
    Decode.map2 AuditLogMsg
        (field "message" string)
        (field "commands" (list string))
