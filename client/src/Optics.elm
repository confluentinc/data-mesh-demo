module Optics exposing (..)

{-| Optics are composable getters and setters, for peeking into values and/or changing their values.
-}

import GenericDict as Dict exposing (Dict)
import GenericDict.Extra as Dict
import Monocle.Common
import Monocle.Compose exposing (..)
import Monocle.Lens exposing (..)
import Monocle.Optional exposing (..)
import Monocle.Prism exposing (..)
import Monocle.Traversal exposing (..)
import RemoteData exposing (WebData)
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
stream q =
    streams
        |> lensWithPrism RemoteData.prism
        |> optionalWithOptional (Dict.optional unQualifiedName q)


dataProduct : Optional Stream DataProduct
dataProduct =
    Optional
        (\s ->
            case s of
                StreamDataProduct r ->
                    Just r

                StreamTopic r ->
                    Nothing
        )
        (\new s ->
            case s of
                StreamDataProduct _ ->
                    StreamDataProduct new

                StreamTopic t ->
                    StreamTopic t
        )


streamDataProduct : QualifiedName -> Optional Model DataProduct
streamDataProduct =
    stream >> optionalWithOptional dataProduct
