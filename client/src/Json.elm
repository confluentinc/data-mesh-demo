module Json exposing (decodeDataProducts)

import Json.Decode as Decode exposing (..)
import Types exposing (DataProduct, DataProductUrls)
import Url as Url exposing (Url)


decodeDataProducts : Decoder (List DataProduct)
decodeDataProducts =
    list decodeDataProduct


decodeDataProduct : Decoder DataProduct
decodeDataProduct =
    map5 DataProduct
        (field "qualifiedName" string)
        (field "name" string)
        (field "description" string)
        (field "owner" string)
        (field "urls" decodeDataProductUrls)


decodeDataProductUrls : Decoder DataProductUrls
decodeDataProductUrls =
    map3 DataProductUrls
        (field "schemaUrl" url)
        (field "portUrl" url)
        (field "lineageUrl" url)


url : Decoder Url
url =
    string
        |> Decode.andThen
            (\str ->
                case
                    Url.fromString str
                of
                    Nothing ->
                        fail ("Expected URL, got: " ++ str)

                    Just decoded ->
                        succeed decoded
            )
