module Rest exposing
    ( getStreams
    , publishDataProduct
    )

import GenericDict as Dict
import GenericDict.Extra as Dict
import Http exposing (Expect, expectJson, get)
import Json exposing (decodeStreams)
import Json.Decode exposing (Decoder)
import RemoteData exposing (WebData)
import Task
import Types exposing (Msg(..), PublishModel, QualifiedName, streamQualifiedName, unQualifiedName)
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


{-| TODO Placeholder
-}
publishDataProduct : PublishModel -> Cmd Msg
publishDataProduct publishModel =
    DataProductPublished publishModel
        |> Debug.log "Publishing"
        |> Task.succeed
        |> Task.perform identity


expectRemoteData : (WebData a -> msg) -> Decoder a -> Expect msg
expectRemoteData wrapper =
    expectJson
        (RemoteData.fromResult
            >> wrapper
        )
