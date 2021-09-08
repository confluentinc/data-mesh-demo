module Tests exposing (..)

import DecodersTests
import EncodersTests
import Fuzz exposing (Fuzzer, int, list, string)
import Json.ExtrasTests
import Route exposing (routeParser, routeToString)
import RouteTests
import Test exposing (..)
import Types exposing (..)
import Url as Url
import Url.Parser as Url exposing (Parser, map, oneOf, s)


suite : Test
suite =
    describe "All"
        [ RouteTests.suite
        , DecodersTests.suite
        , EncodersTests.suite
        , Json.ExtrasTests.suite
        ]
