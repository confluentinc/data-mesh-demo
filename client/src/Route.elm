module Route exposing
    ( routeParser
    , routeToString
    )

import Dialog.Common exposing (maybe)
import Types exposing (..)
import Url as Url exposing (Url)
import Url.Parser as Url exposing ((</>), Parser, map, oneOf, s, string, top)


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
        [ map (Discover Nothing) top
        , map (Discover Nothing) (s "discover")
        , map (Discover << Just << QualifiedName) (s "discover" </> string)
        , map (Create Nothing) (s "create")
        , map (Create << Just) (s "create" </> string)
        , map Manage (s "manage")
        ]


routeToString : View -> String
routeToString view =
    "#/" ++ String.join "/" (routeToPieces view)


routeToPieces : View -> List String
routeToPieces view =
    case view of
        Discover mQualifiedName ->
            [ "discover" ]
                ++ (case mQualifiedName of
                        Nothing ->
                            []

                        Just qualifiedName ->
                            [ unQualifiedName qualifiedName ]
                   )

        Create mName ->
            [ "create" ]
                ++ (case mName of
                        Nothing ->
                            []

                        Just name ->
                            [ name ]
                   )

        Manage ->
            [ "manage" ]

        NotFound ->
            []
