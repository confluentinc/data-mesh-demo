module Decoders exposing
    ( decodeDataProduct
    , decodeStream
    , decodeStreams
    )

import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing (url, when)
import RemoteData exposing (RemoteData(..))
import Types exposing (..)
import Url as Url exposing (Url)


whenTypeIs tag =
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
    whenTypeIs "Topic" <|
        Decode.map2 Topic
            (field "qualifiedName" qualifiedName)
            (field "name" string)


decodeDataProduct : Decoder DataProduct
decodeDataProduct =
    whenTypeIs "DataProduct" <|
        Decode.map5 DataProduct
            (field "qualifiedName" qualifiedName)
            (field "name" string)
            (field "description" string)
            (field "owner" string)
            (field "urls" decodeDataProductUrls)


qualifiedName : Decoder QualifiedName
qualifiedName =
    Decode.map QualifiedName string


decodeDataProductUrls : Decoder DataProductUrls
decodeDataProductUrls =
    Decode.map3 DataProductUrls
        (field "schemaUrl" url)
        (field "portUrl" url)
        (field "lineageUrl" url)
