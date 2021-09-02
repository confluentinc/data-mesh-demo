module RouteTests exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Route exposing (routeParser, routeToString)
import Test exposing (..)
import Types exposing (..)
import Url as Url
import Url.Parser as Url exposing (Parser, map, oneOf, s)


suite : Test
suite =
    describe "Route"
        [ describe
            "routeParser"
            [ test "root" <|
                \_ -> parsesTo Discover "http://localhost/"
            , test "discover" <|
                \_ -> parsesTo Discover "http://localhost/#discover"
            , test "create" <|
                \_ -> parsesTo Create "http://localhost/#create"
            , test "manage" <|
                \_ -> parsesTo Manage "http://localhost/#manage"
            ]
        , describe
            "routeToString"
            [ test "discover" <| \_ -> Expect.equal "#/discover" (routeToString Discover)
            , test "create" <| \_ -> Expect.equal "#/create" (routeToString Create)
            , test "manage" <| \_ -> Expect.equal "#/manage" (routeToString Manage)
            ]
        ]


parsesTo : View -> String -> Expectation
parsesTo expected urlString =
    Expect.equal (Just expected)
        (urlString
            |> Url.fromString
            |> Maybe.map routeParser
        )
