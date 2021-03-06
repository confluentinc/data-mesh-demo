module Optics exposing (..)

{-| Optics are composable getters and setters, for peeking into values and/or changing their values.
-}

import Array exposing (Array)
import GenericDict.Extra as Dict
import Monocle.Compose exposing (..)
import Monocle.Lens exposing (..)
import Monocle.Optional exposing (..)
import RemoteData
import Stomp exposing (AuditLogMsg)
import Types exposing (..)


streams : Lens { s | streams : a } a
streams =
    Lens .streams (\a s -> { s | streams = a })


qualifiedName : Lens QualifiedName String
qualifiedName =
    Lens unQualifiedName (\str _ -> QualifiedName str)


streamQualifiedName : Lens Stream QualifiedName
streamQualifiedName =
    Lens
        (\s ->
            case s of
                StreamDataProduct r ->
                    r.qualifiedName

                StreamTopic r ->
                    r.qualifiedName
        )
        (\newQualifiedName s ->
            case s of
                StreamDataProduct r ->
                    StreamDataProduct { r | qualifiedName = newQualifiedName }

                StreamTopic r ->
                    StreamTopic
                        { r | qualifiedName = newQualifiedName }
        )


streamName : Lens Stream String
streamName =
    Lens
        (\s ->
            case s of
                StreamDataProduct r ->
                    r.name

                StreamTopic r ->
                    r.name
        )
        (\newName s ->
            case s of
                StreamDataProduct r ->
                    StreamDataProduct { r | name = newName }

                StreamTopic r ->
                    StreamTopic
                        { r | name = newName }
        )


stream : QualifiedName -> Optional Model Stream
stream name =
    streams
        |> lensWithPrism RemoteData.prism
        |> optionalWithOptional (Dict.optional unQualifiedName name)


dataProduct : Optional Stream DataProduct
dataProduct =
    Optional
        (\s ->
            case s of
                StreamDataProduct r ->
                    Just r

                StreamTopic _ ->
                    Nothing
        )
        (\new s ->
            case s of
                StreamDataProduct _ ->
                    StreamDataProduct new

                StreamTopic t ->
                    StreamTopic t
        )


topic : Optional Stream Topic
topic =
    Optional
        (\s ->
            case s of
                StreamDataProduct _ ->
                    Nothing

                StreamTopic r ->
                    Just r
        )
        (\new s ->
            case s of
                StreamDataProduct d ->
                    StreamDataProduct d

                StreamTopic _ ->
                    StreamTopic new
        )


streamDataProduct : QualifiedName -> Optional Model DataProduct
streamDataProduct name =
    optionalWithOptional
        dataProduct
        (stream name)


streamTopic : QualifiedName -> Optional Model Topic
streamTopic name =
    optionalWithOptional
        topic
        (stream name)


auditLogModel : Lens { s | auditLogModel : a } a
auditLogModel =
    Lens .auditLogModel (\a s -> { s | auditLogModel = a })


messages : Lens { s | messages : a } a
messages =
    Lens .messages (\a s -> { s | messages = a })


auditLogMessages : Lens Model (Array (Result String AuditLogMsg))
auditLogMessages =
    lensWithLens
        messages
        auditLogModel


minimised : Lens { s | minimised : a } a
minimised =
    Lens .minimised (\a s -> { s | minimised = a })


stompSession : Lens { s | stompSession : a } a
stompSession =
    Lens .stompSession (\a s -> { s | stompSession = a })
