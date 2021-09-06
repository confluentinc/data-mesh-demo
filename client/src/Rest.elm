module Rest exposing
    ( getDataProducts
    , publishDataProduct
    )

import GenericDict as Dict
import GenericDict.Extra as Dict
import Http exposing (Expect, expectJson, get)
import Json exposing (decodeDataProducts)
import Json.Decode exposing (Decoder)
import RemoteData exposing (WebData)
import Types exposing (Msg(..), QualifiedName, unQualifiedName)
import Url.Builder exposing (absolute)


getDataProducts : Cmd Msg
getDataProducts =
    get
        { url = absolute [ "api", "data-products" ] []
        , expect =
            expectRemoteData
                (RemoteData.map (Dict.fromListBy .qualifiedName unQualifiedName)
                    >> GotDataProducts
                )
                decodeDataProducts
        }


publishDataProduct : QualifiedName -> Cmd Msg
publishDataProduct qualifiedName =
    Cmd.none


expectRemoteData : (WebData a -> msg) -> Decoder a -> Expect msg
expectRemoteData wrapper =
    expectJson
        (RemoteData.fromResult
            >> wrapper
        )
