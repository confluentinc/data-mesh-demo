module TestUtils exposing
    ( decodesTo
    , encodesTo
    , expectContains
    )

import Expect exposing (Expectation, fail)
import Json.Decode exposing (Decoder, decodeString, errorToString)
import Json.Encode exposing (Value, encode)


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


encodesTo : (a -> Value) -> String -> a -> Expectation
encodesTo encoder expected value =
    Expect.equal
        (String.trim expected)
        (encode 2 (encoder value))


expectContains : a -> List a -> Expectation
expectContains expected actual =
    if List.member expected actual then
        Expect.pass

    else
        Expect.fail ("Expected list containing: " ++ Debug.toString expected ++ "\nGot: " ++ Debug.toString actual)
