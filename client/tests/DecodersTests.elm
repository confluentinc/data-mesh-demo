module DecodersTests exposing (suite)

import Decoders exposing (decodeStream, decodeStreams)
import Expect exposing (Expectation, fail, pass)
import Fuzz exposing (Fuzzer, int, list, string)
import Json.Decode exposing (Decoder, decodeString, errorToString)
import Json.Encode exposing (encode)
import RemoteData exposing (RemoteData(..))
import Test exposing (..)
import TestUtils exposing (decodesTo)
import Types exposing (..)
import Url exposing (Protocol(..))


suite : Test
suite =
    describe "Decoders"
        [ describe
            "Decode Streams"
            [ test "publish response - correct result" <|
                \_ ->
                    decodesTo decodeStream
                        publishDataProductResponse1
                        (StreamDataProduct
                            { description = "website pageviews"
                            , name = "pageviews"
                            , owner = "kris"
                            , qualifiedName = QualifiedName "lsrc-odr89:.:pageviews-value:1"
                            , urls =
                                { exportUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-jn132/clusters/lkc-17pzv/connectors/browse"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , lineageUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-jn132/clusters/lkc-17pzv/stream-lineage/stream/topic-pageviews/n/topic-pageviews/overview"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , portUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-jn132/clusters/lkc-17pzv/topics/pageviews"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , schemaUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-jn132/schema-registry/schemas/pageviews-value"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                }
                            }
                        )
            , test "streams response - correct result" <|
                \_ ->
                    decodesTo decodeStreams
                        dataProductsResponse1
                        [ StreamDataProduct
                            { description = "website users"
                            , name = "users"
                            , owner = "kris"
                            , qualifiedName = QualifiedName "lsrc-odr89:.:users-value:1"
                            , urls =
                                { lineageUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path =
                                        "/environments/env-jn132/clusters/lkc-17pzv/stream-lineage/stream/topic-users/n/topic-users/overview"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , portUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-jn132/clusters/lkc-17pzv/topics/users"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , schemaUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-jn132/schema-registry/schemas/users-value"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , exportUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-jn132/clusters/lkc-17pzv/connectors/browse"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                }
                            }
                        , StreamTopic
                            { name = "pageviews"
                            , qualifiedName = QualifiedName "lsrc-odr89:.:pageviews-value:1"
                            }
                        ]
            ]
        ]


dataProductsResponse1 : String
dataProductsResponse1 =
    """
[
  {
    "@type": "DataProduct",
    "name": "users",
    "qualifiedName": "lsrc-odr89:.:users-value:1",
    "description": "website users",
    "owner": "kris",
    "urls": {
      "schemaUrl": "https://confluent.cloud/environments/env-jn132/schema-registry/schemas/users-value",
      "portUrl": "https://confluent.cloud/environments/env-jn132/clusters/lkc-17pzv/topics/users",
      "lineageUrl": "https://confluent.cloud/environments/env-jn132/clusters/lkc-17pzv/stream-lineage/stream/topic-users/n/topic-users/overview",
      "exportUrl": "https://confluent.cloud/environments/env-jn132/clusters/lkc-17pzv/connectors/browse"
    }
  },
  {
    "@type": "Topic",
    "name": "pageviews",
    "qualifiedName": "lsrc-odr89:.:pageviews-value:1"
  }
]
"""


publishDataProductResponse1 : String
publishDataProductResponse1 =
    """
{
  "@type": "DataProduct",
  "name": "pageviews",
  "qualifiedName": "lsrc-odr89:.:pageviews-value:1",
  "description": "website pageviews",
  "owner": "kris",
  "urls": {
    "schemaUrl": "https://confluent.cloud/environments/env-jn132/schema-registry/schemas/pageviews-value",
    "portUrl": "https://confluent.cloud/environments/env-jn132/clusters/lkc-17pzv/topics/pageviews",
    "lineageUrl": "https://confluent.cloud/environments/env-jn132/clusters/lkc-17pzv/stream-lineage/stream/topic-pageviews/n/topic-pageviews/overview",
    "exportUrl": "https://confluent.cloud/environments/env-jn132/clusters/lkc-17pzv/connectors/browse"
  }
}
"""
