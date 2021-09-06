module Rest exposing
    ( deleteDataProduct
    , getStreams
    , publishDataProduct
    )

import GenericDict as Dict
import GenericDict.Extra as Dict
import Http exposing (Expect, expectJson, expectWhatever, get)
import Http.Extra exposing (delete)
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
