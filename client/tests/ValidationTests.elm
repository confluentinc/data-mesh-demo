module ValidationTests exposing (suite)

import Expect exposing (Expectation, fail, pass)
import Test exposing (..)
import Types exposing (..)
import Validate exposing (Validator, validate)


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


validateOk : Validator e a -> a -> Expectation
validateOk validator input =
    case validate validator input of
        Ok _ ->
            pass

        Err err ->
            fail ("Expected validation to pass. Got: " ++ Debug.toString err)


validateErr : Validator e a -> List e -> a -> Expectation
validateErr validator expected input =
    case validate validator input of
        Ok _ ->
            fail "Expected an error, but validation passed."

        Err err ->
            Expect.equal expected err
