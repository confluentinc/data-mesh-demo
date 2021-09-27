module Decoders exposing
    ( decodeDataProduct
    , decodeStream
    , decodeStreams
    , decodeUseCases
    )

import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing (url, when)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import RemoteData exposing (RemoteData(..))
import Types exposing (..)
import Url as Url exposing (Url)


ensureTypeIs : String -> Decoder (a -> b) -> Decoder (a -> b)
ensureTypeIs tag =
    when (field "@type" string) ((==) tag)


decodeStreams : Decoder (List Stream)
decodeStreams =
    list decodeStream


decodeStream : Decoder Stream
decodeStream =
    oneOf
        [ Decode.map StreamDataProduct decodeDataProduct
        , Decode.map StreamTopic decodeTopic
        ]


decodeTopic : Decoder Topic
decodeTopic =
    succeed Topic
        |> ensureTypeIs "Topic"
        |> required "qualifiedName" qualifiedName
        |> required "name" string


decodeDataProduct : Decoder DataProduct
decodeDataProduct =
    succeed DataProduct
        |> ensureTypeIs "DataProduct"
        |> required "qualifiedName" qualifiedName
        |> required "name" string
        |> required "domain" string
        |> required "description" string
        |> required "owner" string
        |> required "urls" decodeDataProductUrls
        |> required "schema" decodeKsqlSchema
        |> required "quality" string
        |> required "sla" string


qualifiedName : Decoder QualifiedName
qualifiedName =
    Decode.map QualifiedName string


decodeDataProductUrls : Decoder DataProductUrls
decodeDataProductUrls =
    succeed DataProductUrls
        |> required "schemaUrl" url
        |> required "portUrl" url
        |> required "lineageUrl" url
        |> required "exportUrl" url


decodeKsqlSchema : Decoder KsqlSchema
decodeKsqlSchema =
    succeed KsqlSchema
        |> required "subject" string
        |> required "version" int
        |> required "id" int
        |> required "schema" string


decodeUseCases : Decoder (List UseCase)
decodeUseCases =
    list decodeUseCase


decodeUseCase : Decoder UseCase
decodeUseCase =
    succeed UseCase
        |> required "description" string
        |> required "name" string
        |> required "inputs" string
        |> required "ksqlDbCommand" string
        |> required "ksqlDbLaunchUrl" url
        |> required "outputTopic" string
