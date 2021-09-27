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
                            , domain = "edge"
                            , name = "users"
                            , owner = "@edge-team"
                            , qualifiedName = QualifiedName "lsrc-jj2vp:.:users-value:1"
                            , quality = Authoritative
                            , schema =
                                { id = 100002
                                , schema = "{\"type\":\"record\",\"name\":\"users\",\"namespace\":\"ksql\",\"fields\":[{\"name\":\"registertime\",\"type\":\"long\"},{\"name\":\"userid\",\"type\":\"string\"},{\"name\":\"regionid\",\"type\":\"string\"},{\"name\":\"gender\",\"type\":\"string\"}],\"connect.name\":\"ksql.users\"}"
                                , subject = "users-value"
                                , version = 1
                                }
                            , sla = OtherSla "14d"
                            , urls =
                                { exportUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-qyjxp/clusters/lkc-9mozm/connectors/browse"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , lineageUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-qyjxp/clusters/lkc-9mozm/stream-lineage/stream/topic-users/n/topic-users/overview"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , portUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-qyjxp/clusters/lkc-9mozm/topics/users"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , schemaUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-qyjxp/schema-registry/schemas/users-value"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                }
                            }
                        , StreamDataProduct
                            { description = "website pageviews"
                            , domain = "edge"
                            , name = "pageviews"
                            , owner = "@edge-team"
                            , qualifiedName = QualifiedName "lsrc-jj2vp:.:pageviews-value:1"
                            , quality = Authoritative
                            , schema =
                                { id = 100001
                                , schema = "{\"type\":\"record\",\"name\":\"pageviews\",\"namespace\":\"ksql\",\"fields\":[{\"name\":\"viewtime\",\"type\":\"long\"},{\"name\":\"userid\",\"type\":\"string\"},{\"name\":\"pageid\",\"type\":\"string\"}],\"connect.name\":\"ksql.pageviews\"}"
                                , subject = "pageviews-value"
                                , version = 1
                                }
                            , sla = Tier1
                            , urls =
                                { exportUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-qyjxp/clusters/lkc-9mozm/connectors/browse"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , lineageUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-qyjxp/clusters/lkc-9mozm/stream-lineage/stream/topic-pageviews/n/topic-pageviews/overview"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , portUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-qyjxp/clusters/lkc-9mozm/topics/pageviews"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , schemaUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-qyjxp/schema-registry/schemas/pageviews-value"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                }
                            }
                        , StreamDataProduct
                            { description = "Pageviews count by user"
                            , domain = "n/a"
                            , name = "pageviews_count_by_user"
                            , owner = "@edge-team"
                            , qualifiedName = QualifiedName "lsrc-jj2vp:.:pageviews_count_by_user-value:2"
                            , quality = OtherQuality "n/a"
                            , schema =
                                { id = 100006
                                , schema = "{\"type\":\"record\",\"name\":\"KsqlDataSourceSchema\",\"namespace\":\"io.confluent.ksql.avro_schemas\",\"fields\":[{\"name\":\"NUMUSERS\",\"type\":[\"null\",\"long\"],\"default\":null}]}"
                                , subject = "pageviews_count_by_user-value"
                                , version = 2
                                }
                            , sla = OtherSla "n/a"
                            , urls =
                                { exportUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-qyjxp/clusters/lkc-9mozm/connectors/browse"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , lineageUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-qyjxp/clusters/lkc-9mozm/stream-lineage/stream/topic-pageviews_count_by_user/n/topic-pageviews_count_by_user/overview"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , portUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-qyjxp/clusters/lkc-9mozm/topics/pageviews_count_by_user"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , schemaUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-qyjxp/schema-registry/schemas/pageviews_count_by_user-value"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                }
                            }
                        ]
            , test
                "publish response - correct result"
              <|
                \_ ->
                    decodesTo decodeStream
                        publishDataProductResponse1
                        (StreamDataProduct
                            { description = "Pageviews"
                            , domain = "n/a"
                            , name = "pageviews"
                            , owner = "@edge-team"
                            , qualifiedName = QualifiedName "lsrc-jj2vp:.:pageviews-value:1"
                            , quality = OtherQuality "n/a"
                            , schema = { id = 100001, schema = "{\"type\":\"record\",\"name\":\"pageviews\",\"namespace\":\"ksql\",\"fields\":[{\"name\":\"viewtime\",\"type\":\"long\"},{\"name\":\"userid\",\"type\":\"string\"},{\"name\":\"pageid\",\"type\":\"string\"}],\"connect.name\":\"ksql.pageviews\"}", subject = "pageviews-value", version = 1 }
                            , sla = OtherSla "n/a"
                            , urls =
                                { exportUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-qyjxp/clusters/lkc-9mozm/connectors/browse"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , lineageUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-qyjxp/clusters/lkc-9mozm/stream-lineage/stream/topic-pageviews/n/topic-pageviews/overview"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , portUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-qyjxp/clusters/lkc-9mozm/topics/pageviews"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , schemaUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-qyjxp/schema-registry/schemas/pageviews-value"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
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
                      , ksqlDbCommand = "CREATE STREAM PAGEVIEWS_ENRICHED\n    with (kafka_topic='pageviews_enriched')\n    AS SELECT U.ID AS USERID, U.REGIONID AS REGION,\n        U.GENDER AS GENDER, V.PAGEID AS PAGE\n    FROM PAGEVIEWS V INNER JOIN USERS U \n    ON V.USERID = U.ID;"
                      , ksqlDbLaunchUrl =
                            { fragment = Nothing
                            , host = "confluent.cloud"
                            , path = "/environments/env-qyjxp/clusters/lkc-9mozm/ksql/lksqlc-rng0p/editor"
                            , port_ = Nothing
                            , protocol = Https
                            , query = Just "command=CREATE%20STREAM%20PAGEVIEWS_ENRICHED%0A%20%20%20%20with%20%28kafka_topic%3D%27pageviews_enriched%27%29%0A%20%20%20%20AS%20SELECT%20U.ID%20AS%20USERID%2C%20U.REGIONID%20AS%20REGION%2C%0A%20%20%20%20%20%20%20%20U.GENDER%20AS%20GENDER%2C%20V.PAGEID%20AS%20PAGE%0A%20%20%20%20FROM%20PAGEVIEWS%20V%20INNER%20JOIN%20USERS%20U%20%0A%20%20%20%20ON%20V.USERID%20%3D%20U.ID%3B&ksqlClusterId=lksqlc-rng0p&properties=%7B%22auto.offset.reset%22%3A%22latest%22%7D"
                            }
                      , name = "pageviews_enriched"
                      , outputTopic = "pageviews_enriched"
                      }
                    , { description = "Filter an event stream"
                      , inputs = "pageviews"
                      , ksqlDbCommand = "CREATE STREAM PAGEVIEWS_FILTERED_USER_1\n    with (kafka_topic='pageviews_filtered_user_1')\n    AS SELECT * FROM PAGEVIEWS WHERE USERID = 'User_1';"
                      , ksqlDbLaunchUrl =
                            { fragment = Nothing
                            , host = "confluent.cloud"
                            , path = "/environments/env-qyjxp/clusters/lkc-9mozm/ksql/lksqlc-rng0p/editor"
                            , port_ = Nothing
                            , protocol = Https
                            , query = Just "command=CREATE%20STREAM%20PAGEVIEWS_FILTERED_USER_1%0A%20%20%20%20with%20%28kafka_topic%3D%27pageviews_filtered_user_1%27%29%0A%20%20%20%20AS%20SELECT%20%2A%20FROM%20PAGEVIEWS%20WHERE%20USERID%20%3D%20%27User_1%27%3B&ksqlClusterId=lksqlc-rng0p&properties=%7B%22auto.offset.reset%22%3A%22latest%22%7D"
                            }
                      , name = "pageviews_filtered_user_1"
                      , outputTopic = "pageviews_filtered_user_1"
                      }
                    , { description = "Aggregate an event stream"
                      , inputs = "pageviews"
                      , ksqlDbCommand = "CREATE TABLE PAGEVIEWS_COUNT_BY_USER\n    with (kafka_topic='pageviews_count_by_user')\n    AS SELECT USERID, COUNT(*) AS numusers\n    FROM PAGEVIEWS WINDOW TUMBLING (size 30 second)\n    GROUP BY USERID HAVING COUNT(*) > 1;"
                      , ksqlDbLaunchUrl =
                            { fragment = Nothing
                            , host = "confluent.cloud"
                            , path = "/environments/env-qyjxp/clusters/lkc-9mozm/ksql/lksqlc-rng0p/editor"
                            , port_ = Nothing
                            , protocol = Https
                            , query = Just "command=CREATE%20TABLE%20PAGEVIEWS_COUNT_BY_USER%0A%20%20%20%20with%20%28kafka_topic%3D%27pageviews_count_by_user%27%29%0A%20%20%20%20AS%20SELECT%20USERID%2C%20COUNT%28%2A%29%20AS%20numusers%0A%20%20%20%20FROM%20PAGEVIEWS%20WINDOW%20TUMBLING%20%28size%2030%20second%29%0A%20%20%20%20GROUP%20BY%20USERID%20HAVING%20COUNT%28%2A%29%20%3E%201%3B&ksqlClusterId=lksqlc-rng0p&properties=%7B%22auto.offset.reset%22%3A%22latest%22%7D"
                            }
                      , name = "pageviews_count_by_user"
                      , outputTopic = "pageviews_count_by_user"
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
    "qualifiedName": "lsrc-jj2vp:.:users-value:1",
    "description": "website users",
    "owner": "@edge-team",
    "domain": "edge",
    "sla": "14d",
    "quality": "authoritative",
    "urls": {
      "schemaUrl": "https://confluent.cloud/environments/env-qyjxp/schema-registry/schemas/users-value",
      "portUrl": "https://confluent.cloud/environments/env-qyjxp/clusters/lkc-9mozm/topics/users",
      "lineageUrl": "https://confluent.cloud/environments/env-qyjxp/clusters/lkc-9mozm/stream-lineage/stream/topic-users/n/topic-users/overview",
      "exportUrl": "https://confluent.cloud/environments/env-qyjxp/clusters/lkc-9mozm/connectors/browse"
    },
    "schema": {
      "subject": "users-value",
      "version": 1,
      "id": 100002,
      "schema": "{\\"type\\":\\"record\\",\\"name\\":\\"users\\",\\"namespace\\":\\"ksql\\",\\"fields\\":[{\\"name\\":\\"registertime\\",\\"type\\":\\"long\\"},{\\"name\\":\\"userid\\",\\"type\\":\\"string\\"},{\\"name\\":\\"regionid\\",\\"type\\":\\"string\\"},{\\"name\\":\\"gender\\",\\"type\\":\\"string\\"}],\\"connect.name\\":\\"ksql.users\\"}"
    }
  },
  {
    "@type": "DataProduct",
    "name": "pageviews",
    "qualifiedName": "lsrc-jj2vp:.:pageviews-value:1",
    "description": "website pageviews",
    "owner": "@edge-team",
    "domain": "edge",
    "sla": "tier-1",
    "quality": "authoritative",
    "urls": {
      "schemaUrl": "https://confluent.cloud/environments/env-qyjxp/schema-registry/schemas/pageviews-value",
      "portUrl": "https://confluent.cloud/environments/env-qyjxp/clusters/lkc-9mozm/topics/pageviews",
      "lineageUrl": "https://confluent.cloud/environments/env-qyjxp/clusters/lkc-9mozm/stream-lineage/stream/topic-pageviews/n/topic-pageviews/overview",
      "exportUrl": "https://confluent.cloud/environments/env-qyjxp/clusters/lkc-9mozm/connectors/browse"
    },
    "schema": {
      "subject": "pageviews-value",
      "version": 1,
      "id": 100001,
      "schema": "{\\"type\\":\\"record\\",\\"name\\":\\"pageviews\\",\\"namespace\\":\\"ksql\\",\\"fields\\":[{\\"name\\":\\"viewtime\\",\\"type\\":\\"long\\"},{\\"name\\":\\"userid\\",\\"type\\":\\"string\\"},{\\"name\\":\\"pageid\\",\\"type\\":\\"string\\"}],\\"connect.name\\":\\"ksql.pageviews\\"}"
    }
  },
  {
    "@type": "DataProduct",
    "name": "pageviews_count_by_user",
    "qualifiedName": "lsrc-jj2vp:.:pageviews_count_by_user-value:2",
    "description": "Pageviews count by user",
    "owner": "@edge-team",
    "domain": "n/a",
    "sla": "n/a",
    "quality": "n/a",
    "urls": {
      "schemaUrl": "https://confluent.cloud/environments/env-qyjxp/schema-registry/schemas/pageviews_count_by_user-value",
      "portUrl": "https://confluent.cloud/environments/env-qyjxp/clusters/lkc-9mozm/topics/pageviews_count_by_user",
      "lineageUrl": "https://confluent.cloud/environments/env-qyjxp/clusters/lkc-9mozm/stream-lineage/stream/topic-pageviews_count_by_user/n/topic-pageviews_count_by_user/overview",
      "exportUrl": "https://confluent.cloud/environments/env-qyjxp/clusters/lkc-9mozm/connectors/browse"
    },
    "schema": {
      "subject": "pageviews_count_by_user-value",
      "version": 2,
      "id": 100006,
      "schema": "{\\"type\\":\\"record\\",\\"name\\":\\"KsqlDataSourceSchema\\",\\"namespace\\":\\"io.confluent.ksql.avro_schemas\\",\\"fields\\":[{\\"name\\":\\"NUMUSERS\\",\\"type\\":[\\"null\\",\\"long\\"],\\"default\\":null}]}"
    }
  }
]
"""


publishDataProductResponse1 : String
publishDataProductResponse1 =
    """
{
  "@type": "DataProduct",
  "name": "pageviews",
  "qualifiedName": "lsrc-jj2vp:.:pageviews-value:1",
  "description": "Pageviews",
  "owner": "@edge-team",
  "domain": "n/a",
  "sla": "n/a",
  "quality": "n/a",
  "urls": {
    "schemaUrl": "https://confluent.cloud/environments/env-qyjxp/schema-registry/schemas/pageviews-value",
    "portUrl": "https://confluent.cloud/environments/env-qyjxp/clusters/lkc-9mozm/topics/pageviews",
    "lineageUrl": "https://confluent.cloud/environments/env-qyjxp/clusters/lkc-9mozm/stream-lineage/stream/topic-pageviews/n/topic-pageviews/overview",
    "exportUrl": "https://confluent.cloud/environments/env-qyjxp/clusters/lkc-9mozm/connectors/browse"
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
    "ksqlDbCommand": "CREATE STREAM PAGEVIEWS_ENRICHED\\n    with (kafka_topic='pageviews_enriched')\\n    AS SELECT U.ID AS USERID, U.REGIONID AS REGION,\\n        U.GENDER AS GENDER, V.PAGEID AS PAGE\\n    FROM PAGEVIEWS V INNER JOIN USERS U \\n    ON V.USERID = U.ID;",
    "outputTopic": "pageviews_enriched",
    "ksqlDbLaunchUrl": "https://confluent.cloud/environments/env-qyjxp/clusters/lkc-9mozm/ksql/lksqlc-rng0p/editor?command=CREATE%20STREAM%20PAGEVIEWS_ENRICHED%0A%20%20%20%20with%20%28kafka_topic%3D%27pageviews_enriched%27%29%0A%20%20%20%20AS%20SELECT%20U.ID%20AS%20USERID%2C%20U.REGIONID%20AS%20REGION%2C%0A%20%20%20%20%20%20%20%20U.GENDER%20AS%20GENDER%2C%20V.PAGEID%20AS%20PAGE%0A%20%20%20%20FROM%20PAGEVIEWS%20V%20INNER%20JOIN%20USERS%20U%20%0A%20%20%20%20ON%20V.USERID%20%3D%20U.ID%3B&ksqlClusterId=lksqlc-rng0p&properties=%7B%22auto.offset.reset%22%3A%22latest%22%7D"
  },
  {
    "description": "Filter an event stream",
    "name": "pageviews_filtered_user_1",
    "inputs": "pageviews",
    "ksqlDbCommand": "CREATE STREAM PAGEVIEWS_FILTERED_USER_1\\n    with (kafka_topic='pageviews_filtered_user_1')\\n    AS SELECT * FROM PAGEVIEWS WHERE USERID = 'User_1';",
    "outputTopic": "pageviews_filtered_user_1",
    "ksqlDbLaunchUrl": "https://confluent.cloud/environments/env-qyjxp/clusters/lkc-9mozm/ksql/lksqlc-rng0p/editor?command=CREATE%20STREAM%20PAGEVIEWS_FILTERED_USER_1%0A%20%20%20%20with%20%28kafka_topic%3D%27pageviews_filtered_user_1%27%29%0A%20%20%20%20AS%20SELECT%20%2A%20FROM%20PAGEVIEWS%20WHERE%20USERID%20%3D%20%27User_1%27%3B&ksqlClusterId=lksqlc-rng0p&properties=%7B%22auto.offset.reset%22%3A%22latest%22%7D"
  },
  {
    "description": "Aggregate an event stream",
    "name": "pageviews_count_by_user",
    "inputs": "pageviews",
    "ksqlDbCommand": "CREATE TABLE PAGEVIEWS_COUNT_BY_USER\\n    with (kafka_topic='pageviews_count_by_user')\\n    AS SELECT USERID, COUNT(*) AS numusers\\n    FROM PAGEVIEWS WINDOW TUMBLING (size 30 second)\\n    GROUP BY USERID HAVING COUNT(*) > 1;",
    "outputTopic": "pageviews_count_by_user",
    "ksqlDbLaunchUrl": "https://confluent.cloud/environments/env-qyjxp/clusters/lkc-9mozm/ksql/lksqlc-rng0p/editor?command=CREATE%20TABLE%20PAGEVIEWS_COUNT_BY_USER%0A%20%20%20%20with%20%28kafka_topic%3D%27pageviews_count_by_user%27%29%0A%20%20%20%20AS%20SELECT%20USERID%2C%20COUNT%28%2A%29%20AS%20numusers%0A%20%20%20%20FROM%20PAGEVIEWS%20WINDOW%20TUMBLING%20%28size%2030%20second%29%0A%20%20%20%20GROUP%20BY%20USERID%20HAVING%20COUNT%28%2A%29%20%3E%201%3B&ksqlClusterId=lksqlc-rng0p&properties=%7B%22auto.offset.reset%22%3A%22latest%22%7D"
  }
]
"""
