module Json.Extras exposing (prettyPrint)

import Json.Decode as Decode
import Json.Encode as Encode


prettyPrint : String -> Result Decode.Error String
prettyPrint =
    Decode.decodeString Decode.value
        >> Result.map (Encode.encode 2)
