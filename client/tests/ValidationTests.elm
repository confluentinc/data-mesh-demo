module ValidationTests exposing (suite)

import Expect exposing (Expectation, fail, pass)
import Test exposing (..)
import TestUtils exposing (expectContains)
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
                        { description = "Some Description"
                        , owner = "@analytics-team"
                        , quality = Raw
                        , sla = Tier3
                        , topic = { name = "users", qualifiedName = QualifiedName "lsrc-wdzkg:.:users-value:1" }
                        , termsAcknowledged = True
                        }
            , test "validate owner acceptable" <|
                \_ ->
                    validateErr publishFormValidator
                        OwnerInvalid
                        { description = "Some Description"
                        , owner = "Random Name"
                        , quality = Raw
                        , sla = Tier3
                        , topic = { name = "users", qualifiedName = QualifiedName "lsrc-wdzkg:.:users-value:1" }
                        , termsAcknowledged = True
                        }
            , test "validate terms not acknowledged" <|
                \_ ->
                    validateErr publishFormValidator
                        TermsNotAcknowledged
                        { description = "Some Description"
                        , owner = "Rick"
                        , quality = Raw
                        , sla = Tier3
                        , topic = { name = "users", qualifiedName = QualifiedName "lsrc-wdzkg:.:users-value:1" }
                        , termsAcknowledged = False
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


validateErr : Validator e a -> e -> a -> Expectation
validateErr validator expected input =
    case validate validator input of
        Ok _ ->
            fail "Expected an error, but validation passed."

        Err err ->
            expectContains expected err
