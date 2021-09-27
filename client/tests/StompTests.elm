module StompTests exposing (suite)

-- import Decoders exposing (decodeStream, decodeStreams, decodeUseCases)
-- import Expect exposing (Expectation, fail, pass)
-- import Fuzz exposing (Fuzzer, int, list, string)
-- import Json.Decode as Decode exposing (Decoder, decodeString, errorToString)
-- import Json.Encode as Encode exposing (encode)
-- import RemoteData exposing (RemoteData(..))

import Stomp exposing (..)
import Test exposing (..)
import TestUtils exposing (decodesTo)



-- import Types exposing (..)
-- import Url exposing (Protocol(..))


suite : Test
suite =
    describe "Stomp"
        [ describe
            "Decoders"
            [ test "audit log message - correct result" <|
                \_ ->
                    decodesTo decodeAuditLogMsg
                        auditLogMessage1
                        { message = "Search Confluent Cloud Data Catalog"
                        , commands = [ "GET /search/basic?types=sr_subject_version&attrs=version&tag=DataProduct" ]
                        }
            ]
        ]


auditLogMessage1 : String
auditLogMessage1 =
    """
{"message":"Search Confluent Cloud Data Catalog","commands":["GET /search/basic?types=sr_subject_version&attrs=version&tag=DataProduct"]}
"""
