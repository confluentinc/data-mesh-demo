module JsonTests exposing (suite)

import Expect exposing (Expectation, fail, pass)
import Fuzz exposing (Fuzzer, int, list, string)
import Json exposing (decodeDataProducts)
import Json.Decode exposing (Decoder, decodeString, errorToString)
import RemoteData exposing (RemoteData(..))
import Test exposing (..)
import Types exposing (..)
import Url exposing (Protocol(..))


suite : Test
suite =
    describe "JSON"
        [ describe
            "Decode Data Products"
            [ test "sample response 1 - no error" <|
                \_ ->
                    decodesSuccessfully decodeDataProducts dataProductsResponse1
            , test "sample response 2 - no error" <|
                \_ ->
                    decodesSuccessfully decodeDataProducts dataProductsResponse2
            , test "sample response 1 - right result" <|
                \_ ->
                    decodesTo decodeDataProducts
                        dataProductsResponse1
                        [ { description = "website users"
                          , name = "users"
                          , owner = "rick"
                          , isPublished = Success False
                          , qualifiedName = "lsrc-w8v85:.:users-value:1"
                          , urls =
                                { lineageUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-dxy51/clusters/lkc-ypvmp/stream-lineage/view/users-value"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , portUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-dxy51/clusters/lkc-ypvmp/topics/users"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , schemaUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-dxy51/schema-registry/schemas/users-value"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                }
                          }
                        , { description = "website pageviews"
                          , name = "pageviews"
                          , owner = "adam"
                          , isPublished = Success False
                          , qualifiedName = "lsrc-w8v85:.:pageviews-value:1"
                          , urls =
                                { lineageUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-dxy51/clusters/lkc-ypvmp/stream-lineage/view/pageviews-value"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , portUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-dxy51/clusters/lkc-ypvmp/topics/pageviews"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , schemaUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-dxy51/schema-registry/schemas/pageviews-value"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                }
                          }
                        ]
            ]
        ]


dataProductsResponse1 : String
dataProductsResponse1 =
    """
[
  {
    "qualifiedName": "lsrc-w8v85:.:users-value:1",
    "name": "users",
    "description": "website users",
    "owner": "rick",
    "urls": {
      "schemaUrl": "https://confluent.cloud/environments/env-dxy51/schema-registry/schemas/users-value",
      "portUrl": "https://confluent.cloud/environments/env-dxy51/clusters/lkc-ypvmp/topics/users",
      "lineageUrl": "https://confluent.cloud/environments/env-dxy51/clusters/lkc-ypvmp/stream-lineage/view/users-value"
    }
  },
  {
    "qualifiedName": "lsrc-w8v85:.:pageviews-value:1",
    "name": "pageviews",
    "description": "website pageviews",
    "owner": "adam",
    "urls": {
      "schemaUrl": "https://confluent.cloud/environments/env-dxy51/schema-registry/schemas/pageviews-value",
      "portUrl": "https://confluent.cloud/environments/env-dxy51/clusters/lkc-ypvmp/topics/pageviews",
      "lineageUrl": "https://confluent.cloud/environments/env-dxy51/clusters/lkc-ypvmp/stream-lineage/view/pageviews-value"
    }
  }
]
"""


dataProductsResponse2 : String
dataProductsResponse2 =
    """
[
  {
    "qualifiedName": "lsrc-wqg5g:.:users-value:1",
    "name": "users",
    "description": "website users",
    "owner": "rick",
    "urls": {
      "schemaUrl": "https://confluent.cloud/environments/env-dxy51/schema-registry/schemas/users-value",
      "portUrl": "https://confluent.cloud/environments/env-dxy51/clusters/lkc-ypvmp/topics/users",
      "lineageUrl": "https://confluent.cloud/environments/env-dxy51/clusters/lkc-ypvmp/stream-lineage/view/users-value"
    }
  },
  {
    "qualifiedName": "lsrc-wqg5g:.:pageviews-value:1",
    "name": "pageviews",
    "description": "website pageviews",
    "owner": "adam",
    "urls": {
      "schemaUrl": "https://confluent.cloud/environments/env-dxy51/schema-registry/schemas/pageviews-value",
      "portUrl": "https://confluent.cloud/environments/env-dxy51/clusters/lkc-ypvmp/topics/pageviews",
      "lineageUrl": "https://confluent.cloud/environments/env-dxy51/clusters/lkc-ypvmp/stream-lineage/view/pageviews-value"
    }
  }
]
    """


decodesSuccessfully : Decoder a -> String -> Expectation
decodesSuccessfully decoder json =
    let
        decoded =
            decodeString decoder json
    in
    case decoded of
        Ok _ ->
            pass

        Err err ->
            fail (errorToString err)


decodesTo : Decoder a -> String -> a -> Expectation
decodesTo decoder json expected =
    let
        decoded =
            decodeString decoder json
    in
    case decoded of
        Ok actual ->
            Expect.equal expected actual

        Err err ->
            fail (errorToString err)


createProductRequest1 : String
createProductRequest1 =
    """
{
  "@type": "KSQLDB",
  "name": "pageviews_user3",
  "owner": "owner value here",
  "description": "description value here",
  "command": "CREATE STREAM PAGEVIEWS_USER3 WITH (KAFKA_TOPIC='pageviews_user3', PARTITIONS=3, REPLICAS=3) AS SELECT * FROM PAGEVIEWS WHERE (PAGEVIEWS.USERID = 'User_3') EMIT CHANGES;"
}
"""
