module TestUtils exposing
    ( decodesSuccessfully
    , decodesTo
    , encodesTo
    )

import Expect exposing (Expectation, fail, pass)
import Json.Decode exposing (Decoder, decodeString, errorToString)
import Json.Encode exposing (Value, encode)


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


encodesTo : (a -> Value) -> String -> a -> Expectation
encodesTo encoder expected value =
    Expect.equal
        (String.trim expected)
        (encode 2 (encoder value))
