module Rest exposing
    ( deleteDataProduct
    , executeUseCase
    , getActuatorInfo
    , getStreams
    , getUseCases
    , publishDataProduct
    )

import Decoders exposing (decodeActuatorInfo, decodeDataProduct, decodeStreams, decodeUseCases)
import Encoders exposing (encodePublishForm)
import GenericDict.Extra as Dict
import Http exposing (Expect, emptyBody, expectJson, expectWhatever, get, jsonBody, post)
import Http.Extra exposing (delete)
import Json.Decode exposing (Decoder)
import RemoteData exposing (WebData)
import Types exposing (Msg(..), PublishForm, QualifiedName, UseCaseName, streamQualifiedName, unQualifiedName, unUseCaseName)
import Url.Builder exposing (absolute)


getStreams : Cmd Msg
getStreams =
    get
        { url = absolute [ "priv", "data-products", "manage" ] []
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
        { url = absolute [ "priv", "data-products" ] []
        , body = jsonBody (encodePublishForm publishForm)
        , expect =
            expectRemoteData
                DataProductPublished
                decodeDataProduct
        }


deleteDataProduct : QualifiedName -> Cmd Msg
deleteDataProduct qualifiedName =
    delete
        { url = absolute [ "priv", "data-products", unQualifiedName qualifiedName ] []
        , expect =
            expectWhatever
                (RemoteData.fromResult
                    >> RemoteData.map (always qualifiedName)
                    >> DataProductDeleted
                )
        }


getUseCases : Cmd Msg
getUseCases =
    get
        { url = absolute [ "priv", "use-cases" ] []
        , expect =
            expectRemoteData
                (RemoteData.map (Dict.fromListBy .name unUseCaseName)
                    >> GotUseCases
                )
                decodeUseCases
        }


getActuatorInfo : Cmd Msg
getActuatorInfo =
    get
        { url = absolute [ "actuator", "info" ] []
        , expect =
            expectRemoteData
                GotActuatorInfo
                decodeActuatorInfo
        }


expectRemoteData : (WebData a -> msg) -> Decoder a -> Expect msg
expectRemoteData wrapper =
    expectJson
        (RemoteData.fromResult
            >> wrapper
        )


executeUseCase : UseCaseName -> Cmd Msg
executeUseCase useCaseName =
    post
        { url = absolute [ "ksqldb", "execute-use-case", unUseCaseName useCaseName ] []
        , body = emptyBody
        , expect =
            expectWhatever
                (RemoteData.fromResult
                    >> RemoteData.map (always useCaseName)
                    >> UseCaseExecuted
                )
        }
