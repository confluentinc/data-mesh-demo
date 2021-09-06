module DecodersTests exposing (suite)

import Decoders exposing (decodeStreams)
import Expect exposing (Expectation, fail, pass)
import Fuzz exposing (Fuzzer, int, list, string)
import Json.Decode exposing (Decoder, decodeString, errorToString)
import Json.Encode exposing (encode)
import RemoteData exposing (RemoteData(..))
import Test exposing (..)
import Types exposing (..)
import Url exposing (Protocol(..))


suite : Test
suite =
    describe "Decoders"
        [ describe
            "Decode Streams"
            [ test "sample response 1 - no error" <|
                \_ ->
                    decodesSuccessfully decodeStreams dataProductsResponse1
            , test "sample response 2 - no error" <|
                \_ ->
                    decodesSuccessfully decodeStreams dataProductsResponse2
            , test "sample response 2 - right result" <|
                \_ ->
                    decodesTo decodeStreams
                        dataProductsResponse2
                        [ StreamDataProduct
                            { description = "website users"
                            , name = "users"
                            , owner = "rick"
                            , qualifiedName = QualifiedName "lsrc-7xxv2:.:users-value:1"
                            , urls =
                                { lineageUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-6qx3j/clusters/lkc-1771v/stream-lineage/view/users-value"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , portUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-6qx3j/clusters/lkc-1771v/topics/users"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , schemaUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-6qx3j/schema-registry/schemas/users-value"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                }
                            }
                        , StreamDataProduct
                            { description = "website pageviews"
                            , name = "pageviews"
                            , owner = "adam"
                            , qualifiedName = QualifiedName "lsrc-7xxv2:.:pageviews-value:1"
                            , urls =
                                { lineageUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-6qx3j/clusters/lkc-1771v/stream-lineage/view/pageviews-value"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , portUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-6qx3j/clusters/lkc-1771v/topics/pageviews"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                , schemaUrl =
                                    { fragment = Nothing
                                    , host = "confluent.cloud"
                                    , path = "/environments/env-6qx3j/schema-registry/schemas/pageviews-value"
                                    , port_ = Nothing
                                    , protocol = Https
                                    , query = Nothing
                                    }
                                }
                            }
                        , StreamTopic
                            { name = "pksqlc-09g26PAGEVIEWS_USER2"
                            , qualifiedName = QualifiedName "lsrc-7xxv2:.:pksqlc-09g26PAGEVIEWS_USER2-value:2"
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
    "qualifiedName": "lsrc-wqg5g:.:users-value:1",
    "description": "website users",
    "owner": "rick",
    "urls": {
      "schemaUrl": "https://confluent.cloud/environments/env-dxy51/schema-registry/schemas/users-value",
      "portUrl": "https://confluent.cloud/environments/env-dxy51/clusters/lkc-ypvmp/topics/users",
      "lineageUrl": "https://confluent.cloud/environments/env-dxy51/clusters/lkc-ypvmp/stream-lineage/view/users-value"
    }
  },
  {
    "@type": "DataProduct",
    "name": "pageviews",
    "qualifiedName": "lsrc-wqg5g:.:pageviews-value:1",
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
    "@type": "DataProduct",
    "name": "users",
    "qualifiedName": "lsrc-7xxv2:.:users-value:1",
    "description": "website users",
    "owner": "rick",
    "urls": {
      "schemaUrl": "https://confluent.cloud/environments/env-6qx3j/schema-registry/schemas/users-value",
      "portUrl": "https://confluent.cloud/environments/env-6qx3j/clusters/lkc-1771v/topics/users",
      "lineageUrl": "https://confluent.cloud/environments/env-6qx3j/clusters/lkc-1771v/stream-lineage/view/users-value"
    }
  },
  {
    "@type": "DataProduct",
    "name": "pageviews",
    "qualifiedName": "lsrc-7xxv2:.:pageviews-value:1",
    "description": "website pageviews",
    "owner": "adam",
    "urls": {
      "schemaUrl": "https://confluent.cloud/environments/env-6qx3j/schema-registry/schemas/pageviews-value",
      "portUrl": "https://confluent.cloud/environments/env-6qx3j/clusters/lkc-1771v/topics/pageviews",
      "lineageUrl": "https://confluent.cloud/environments/env-6qx3j/clusters/lkc-1771v/stream-lineage/view/pageviews-value"
    }
  },
  {
    "@type": "Topic",
    "name": "pksqlc-09g26PAGEVIEWS_USER2",
    "qualifiedName": "lsrc-7xxv2:.:pksqlc-09g26PAGEVIEWS_USER2-value:2"
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
