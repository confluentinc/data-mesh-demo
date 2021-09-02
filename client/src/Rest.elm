module Rest exposing (getDataProducts)

import Dict.Extra as Dict
import Http exposing (expectJson, get)
import Json exposing (decodeDataProducts)
import RemoteData
import Types exposing (Msg(..))


getDataProducts : Cmd Msg
getDataProducts =
    get
        { url = "/api/data-products"
        , expect =
            expectJson
                (RemoteData.fromResult
                    >> RemoteData.map (Dict.fromListBy .qualifiedName)
                    >> GotDataProducts
                )
                decodeDataProducts
        }
