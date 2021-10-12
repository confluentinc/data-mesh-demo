module ValidationTests exposing (suite)

import Expect exposing (Expectation, fail, pass)
import Fuzz exposing (Fuzzer, int, list, string)
import Json.Decode as Decode exposing (Decoder, decodeString, errorToString)
import Json.Encode as Encode exposing (encode)
import RemoteData exposing (RemoteData(..))
import Test exposing (..)
import TestUtils exposing (decodesTo)
import Types exposing (..)
import Url exposing (Protocol(..))
import Validate exposing (validate)


suite : Test
suite =
    describe "Validation"
        [ describe
            "Validation Publish Form "
            [ test "validate good form" <|
                \_ ->
                    validateOk publishFormValidator
                        { description = "User "
                        , domain = "Product Team"
                        , owner = "Rick"
                        , quality = Raw
                        , sla = Tier3
                        , topic = { name = "users", qualifiedName = QualifiedName "lsrc-wdzkg:.:users-value:1" }
                        }
            , test "validate restricted owner" <|
                \_ ->
                    validateErr publishFormValidator
                        [ RestrictedOwner ]
                        { description = "User "
                        , domain = "Product Team"
                        , owner = "@edge-team"
                        , quality = Curated
                        , sla = Tier2
                        , topic = { name = "users", qualifiedName = QualifiedName "lsrc-wdzkg:.:users-value:1" }
                        }
            ]
        ]


validateOk validator input =
    case validate validator input of
        Ok _ ->
            pass

        Err err ->
            fail ("Expected validation to pass. Got: " ++ Debug.toString err)


validateErr validator expected input =
    case validate validator input of
        Ok _ ->
            fail "Expected an error, but validation passed."

        Err err ->
            Expect.equal expected err
