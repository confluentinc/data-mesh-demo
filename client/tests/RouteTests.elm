module RouteTests exposing (suite)

import Expect exposing (Expectation)
import Route exposing (routeParser, routeToString)
import Test exposing (..)
import Types exposing (..)
import Url


suite : Test
suite =
    describe "Route"
        [ describe
            "routeParser"
            [ test "root" <|
                \_ -> parsesTo Landing "http://localhost/"
            , test "landing" <|
                \_ -> parsesTo Landing "http://localhost/#landing"
            , test "discover" <|
                \_ -> parsesTo (Discover Nothing) "http://localhost/#discover"
            , test "discover/<name>" <|
                \_ -> parsesTo (Discover (Just (QualifiedName "lsrc"))) "http://localhost/#discover/lsrc"
            , test "create" <|
                \_ -> parsesTo (Create Nothing) "http://localhost/#create"
            , test "create/<name>" <|
                \_ -> parsesTo (Create (Just (UseCaseName "enrich"))) "http://localhost/#create/enrich"
            , test "manage" <|
                \_ -> parsesTo Manage "http://localhost/#manage"
            ]
        , describe
            "routeToString"
            [ test "discover" <|
                \_ ->
                    Expect.equal "#/discover" (routeToString (Discover Nothing))
            , test "discover/<name>" <|
                \_ ->
                    Expect.equal "#/discover/crsl" (routeToString (Discover (Just (QualifiedName "crsl"))))
            , test "create" <|
                \_ ->
                    Expect.equal "#/create" (routeToString (Create Nothing))
            , test "create/<name>" <|
                \_ ->
                    Expect.equal "#/create/aggregate" (routeToString (Create (Just (UseCaseName "aggregate"))))
            , test "manage" <|
                \_ ->
                    Expect.equal "#/manage" (routeToString Manage)
            ]
        ]


parsesTo : View -> String -> Expectation
parsesTo expected urlString =
    Expect.equal (Just expected)
        (urlString
            |> Url.fromString
            |> Maybe.map routeParser
        )
