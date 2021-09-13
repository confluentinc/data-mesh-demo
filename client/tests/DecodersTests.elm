module DecodersTests exposing (suite)

import Decoders exposing (decodeStream, decodeStreams, decodeUseCases)
import Expect exposing (Expectation, fail, pass)
import Fuzz exposing (Fuzzer, int, list, string)
import Json.Decode as Decode exposing (Decoder, decodeString, errorToString)
import Json.Encode as Encode exposing (encode)
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
            [ test "streams response - correct result" <|
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
                            , schema =
                                { subject = "users-value"
                                , version = 1
                                , id = 100002
                                , schema = "{\"type\":\"record\",\"name\":\"users\",\"namespace\":\"ksql\",\"fields\":[{\"name\":\"registertime\",\"type\":\"long\"},{\"name\":\"userid\",\"type\":\"string\"},{\"name\":\"regionid\",\"type\":\"string\"},{\"name\":\"gender\",\"type\":\"string\"}],\"connect.name\":\"ksql.users\"}"
                                }
                            }
                        , StreamTopic
                            { name = "pageviews"
                            , qualifiedName = QualifiedName "lsrc-odr89:.:pageviews-value:1"
                            }
                        ]
            , test
                "publish response - correct result"
              <|
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
                            , schema =
                                { subject = "pageviews-value"
                                , version = 1
                                , id = 100001
                                , schema = "{\"type\":\"record\",\"name\":\"pageviews\",\"namespace\":\"ksql\",\"fields\":[{\"name\":\"viewtime\",\"type\":\"long\"},{\"name\":\"userid\",\"type\":\"string\"},{\"name\":\"pageid\",\"type\":\"string\"}],\"connect.name\":\"ksql.pageviews\"}"
                                }
                            }
                        )
            ]
        , test "use-cases response - correct result" <|
            \_ ->
                decodesTo decodeUseCases
                    useCasesResponse1
                    [ { description = "Enrich an event stream"
                      , inputs = "pageviews,users"
                      , ksqlDbCommand = "CREATE TABLE ..."
                      , name = "pageviews_enriched"
                      , outputTopic = "pageviews_enriched"
                      }
                    , { description = "Filter an event stream"
                      , inputs = "pageviews"
                      , ksqlDbCommand = "CREATE STREAM..."
                      , name = "filtered_pageviews"
                      , outputTopic = "filtered_pageviews"
                      }
                    , { description = "Aggregate an event stream"
                      , inputs = "pageviews"
                      , ksqlDbCommand = "CREATE STREAM..."
                      , name = "aggregation"
                      , outputTopic = "aggregation"
                      }
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
    },
    "schema": {
      "subject": "users-value",
      "version": 1,
      "id": 100002,
      "schema": "{\\"type\\":\\"record\\",\\"name\\":\\"users\\",\\"namespace\\":\\"ksql\\",\\"fields\\":[{\\"name\\":\\"registertime\\",\\"type\\":\\"long\\"},{\\"name\\":\\"userid\\",\\"type\\":\\"string\\"},{\\"name\\":\\"regionid\\",\\"type\\":\\"string\\"},{\\"name\\":\\"gender\\",\\"type\\":\\"string\\"}],\\"connect.name\\":\\"ksql.users\\"}"
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
  },
  "schema": {
    "subject": "pageviews-value",
    "version": 1,
    "id": 100001,
    "schema": "{\\"type\\":\\"record\\",\\"name\\":\\"pageviews\\",\\"namespace\\":\\"ksql\\",\\"fields\\":[{\\"name\\":\\"viewtime\\",\\"type\\":\\"long\\"},{\\"name\\":\\"userid\\",\\"type\\":\\"string\\"},{\\"name\\":\\"pageid\\",\\"type\\":\\"string\\"}],\\"connect.name\\":\\"ksql.pageviews\\"}"
  }
}
"""


useCasesResponse1 : String
useCasesResponse1 =
    """
[
  {
    "description": "Enrich an event stream",
    "name": "pageviews_enriched",
    "inputs": "pageviews,users",
    "ksqlDbCommand": "CREATE TABLE ...",
    "outputTopic": "pageviews_enriched"
  },
  {
    "description": "Filter an event stream",
    "name": "filtered_pageviews",
    "inputs": "pageviews",
    "ksqlDbCommand": "CREATE STREAM...",
    "outputTopic": "filtered_pageviews"
  },
  {
    "description": "Aggregate an event stream",
    "name": "aggregation",
    "inputs": "pageviews",
    "ksqlDbCommand": "CREATE STREAM...",
    "outputTopic": "aggregation"
  }
]
"""
