module Tests exposing (..)

import Fuzz exposing (Fuzzer, int, list, string)
import Route exposing (routeParser, routeToString)
import RouteTests
import Test exposing (..)
import Types exposing (..)
import Url as Url
import Url.Parser as Url exposing (Parser, map, oneOf, s)


suite : Test
suite =
    describe "All"
        [RouteTests.suite
        ]
