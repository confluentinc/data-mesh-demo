module Json exposing (decodeDataProducts)

import Json.Decode exposing (..)
import Types exposing (DataProduct)


decodeDataProducts : Decoder (List DataProduct)
decodeDataProducts =
    list decodeDataProduct


decodeDataProduct : Decoder DataProduct
decodeDataProduct =
    map4 DataProduct
        (field "qualifiedName" string)
        (field "name" string)
        (field "description" string)
        (field "owner" string)
