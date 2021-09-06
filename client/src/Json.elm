module Json exposing (decodeStreams)

import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing (url, when)
import RemoteData exposing (RemoteData(..))
import Types exposing (DataProduct, DataProductUrls, QualifiedName(..), Stream(..), Topic)
import Url as Url exposing (Url)


whenTypeIs tag =
    when (field "@type" string) ((==) tag)


decodeStreams : Decoder (List Stream)
decodeStreams =
    list decodeStream


decodeStream : Decoder Stream
decodeStream =
    oneOf
        [ map StreamDataProduct decodeDataProduct
        , map StreamTopic decodeTopic
        ]


decodeTopic : Decoder Topic
decodeTopic =
    whenTypeIs "Topic" <|
        map2 Topic
            (field "qualifiedName" qualifiedName)
            (field "name" string)


decodeDataProduct : Decoder DataProduct
decodeDataProduct =
    whenTypeIs "DataProduct" <|
        map5 DataProduct
            (field "qualifiedName" qualifiedName)
            (field "name" string)
            (field "description" string)
            (field "owner" string)
            (field "urls" decodeDataProductUrls)


qualifiedName : Decoder QualifiedName
qualifiedName =
    map QualifiedName string


decodeDataProductUrls : Decoder DataProductUrls
decodeDataProductUrls =
    map3 DataProductUrls
        (field "schemaUrl" url)
        (field "portUrl" url)
        (field "lineageUrl" url)
