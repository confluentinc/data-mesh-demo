module Rest exposing
    ( deleteDataProduct
    , getStreams
    , publishDataProduct
    )

import Decoders exposing (decodeDataProduct, decodeStreams)
import Encoders exposing (encodePublishForm)
import GenericDict as Dict
import GenericDict.Extra as Dict
import Http exposing (Expect, expectJson, expectWhatever, get, jsonBody, post)
import Http.Extra exposing (delete)
import Json.Decode exposing (Decoder)
import RemoteData exposing (WebData)
import Task
import Types exposing (Msg(..), PublishForm, QualifiedName, streamQualifiedName, unQualifiedName)
import Url.Builder exposing (absolute)


getStreams : Cmd Msg
getStreams =
    get
        { url = absolute [ "api", "data-products", "manage" ] []
        , expect =
            expectRemoteData
                (RemoteData.map (Dict.fromListBy streamQualifiedName unQualifiedName)
                    >> GotStreams
                )
                decodeStreams
        }


publishDataProduct : PublishForm -> Cmd Msg
publishDataProduct publishForm =
    post
        { url = absolute [ "api", "data-products" ] []
        , body = jsonBody (encodePublishForm publishForm)
        , expect =
            expectRemoteData
                DataProductPublished
                decodeDataProduct
        }


deleteDataProduct : QualifiedName -> Cmd Msg
deleteDataProduct qualifiedName =
    delete
        { url = absolute [ "api", "data-products", unQualifiedName qualifiedName ] []
        , expect =
            expectWhatever
                (RemoteData.fromResult
                    >> RemoteData.map (always qualifiedName)
                    >> DataProductDeleted
                )
        }


expectRemoteData : (WebData a -> msg) -> Decoder a -> Expect msg
expectRemoteData wrapper =
    expectJson
        (RemoteData.fromResult
            >> wrapper
        )
