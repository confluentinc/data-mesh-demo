module Tests exposing (suite)

import DecodersTests
import EncodersTests
import Json.ExtrasTests
import RouteTests
import StompTests
import Test exposing (..)
import ValidationTests


suite : Test
suite =
    describe "All"
        [ RouteTests.suite
        , DecodersTests.suite
        , EncodersTests.suite
        , ValidationTests.suite
        , StompTests.suite
        , Json.ExtrasTests.suite
        ]
