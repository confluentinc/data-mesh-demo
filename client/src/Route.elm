module Route exposing (routeParser, routeToString)

import Types exposing (..)
import Url as Url exposing (Url)
import Url.Parser as Url exposing (Parser, map, oneOf, s, top)


routeParser : Url -> View
routeParser url =
    Maybe.withDefault NotFound <|
        Url.parse
            parser
            { url
                | path = Maybe.withDefault "" url.fragment
                , fragment = Nothing
            }


parser : Parser (View -> View) View
parser =
    oneOf
        [ map Discover top
        , map Discover (s "discover")
        , map Create (s "create")
        , map Manage (s "manage")
        ]


routeToString : View -> String
routeToString view =
    "#/" ++ String.join "/" (routeToPieces view)


routeToPieces : View -> List String
routeToPieces view =
    case view of
        Discover ->
            [ "discover" ]

        Create ->
            [ "create" ]

        Manage ->
            [ "manage" ]

        NotFound ->
            []
