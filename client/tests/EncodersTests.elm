module EncodersTests exposing (suite)

import Encoders exposing (encodePublishForm)
import Expect exposing (Expectation, fail, pass)
import Fuzz exposing (Fuzzer, int, list, string)
import Json.Encode exposing (encode)
import RemoteData exposing (RemoteData(..))
import Test exposing (..)
import Types exposing (..)
import Url exposing (Protocol(..))


suite : Test
suite =
    describe "JSON"
        [ describe "encodes publish request"
            [ test "publish request 1 - matches golden encoding." <|
                \_ ->
                    Expect.equal (String.trim publishDataProductRequest1)
                        (encode 2
                            (encodePublishForm
                                { owner = "ybyzek"
                                , description = "pageviews users 2"
                                , topic =
                                    { qualifiedName = QualifiedName "lsrc-7xxv2:.:pksqlc-09g26PAGEVIEWS_USER2-value:2"
                                    , name = "pageviews"
                                    }
                                }
                            )
                        )
            ]
        ]


publishDataProductRequest1 : String
publishDataProductRequest1 =
    """
 {
  "@type": "TOPIC",
  "qualifiedName": "lsrc-7xxv2:.:pksqlc-09g26PAGEVIEWS_USER2-value:2",
  "dataProductTag": {
    "owner": "ybyzek",
    "description": "pageviews users 2"
  }
}
"""
