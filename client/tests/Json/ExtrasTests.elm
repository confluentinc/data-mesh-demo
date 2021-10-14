module Json.ExtrasTests exposing (suite)

import Expect
import Json.Extras exposing (prettyPrint)
import Test exposing (..)


suite : Test
suite =
    describe "Json"
        [ describe
            "prettyPrint"
            [ test "example" <|
                \_ ->
                    Expect.equal
                        (Ok (String.trim prettySchema))
                        (prettyPrint rawSchema)
            ]
        ]


rawSchema : String
rawSchema =
    "{\"type\":\"record\",\"name\":\"users\",\"namespace\":\"ksql\",\"fields\":[{\"name\":\"registertime\",\"type\":\"long\"},{\"name\":\"userid\",\"type\":\"string\"},{\"name\":\"regionid\",\"type\":\"string\"},{\"name\":\"gender\",\"type\":\"string\"}],\"connect.name\":\"ksql.users\"}"


prettySchema : String
prettySchema =
    """
{
  "type": "record",
  "name": "users",
  "namespace": "ksql",
  "fields": [
    {
      "name": "registertime",
      "type": "long"
    },
    {
      "name": "userid",
      "type": "string"
    },
    {
      "name": "regionid",
      "type": "string"
    },
    {
      "name": "gender",
      "type": "string"
    }
  ],
  "connect.name": "ksql.users"
}
"""
