module EncodersTests exposing (suite)

import Encoders exposing (encodePublishForm)
import Test exposing (..)
import TestUtils exposing (encodesTo)
import Types exposing (..)


suite : Test
suite =
    describe "JSON"
        [ describe "encodes publish request"
            [ test "publish request 1 - matches golden encoding." <|
                \_ ->
                    encodesTo encodePublishForm
                        publishDataProductRequest1
                        { owner = "ybyzek"
                        , description = "pageviews users 2"
                        , topic =
                            { qualifiedName = QualifiedName "lsrc-7xxv2:.:pksqlc-09g26PAGEVIEWS_USER2-value:2"
                            , name = "pageviews"
                            }
                        , quality = Authoritative
                        , sla = Tier2
                        , termsAcknowledged = True
                        }
            ]
        ]


publishDataProductRequest1 : String
publishDataProductRequest1 =
    """
{
  "@type": "TOPIC",
  "qualifiedName": "lsrc-7xxv2:.:pksqlc-09g26PAGEVIEWS_USER2-value:2",
  "dataProductBusinessMetadata": {
    "owner": "ybyzek",
    "description": "pageviews users 2",
    "quality": "authoritative",
    "sla": "tier-2"
  }
}
"""
