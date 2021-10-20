module Table.Extras exposing (infoThead, stringColumnWithAttributes)

import Html exposing (Attribute, Html, text)
import Html.Attributes exposing (style)
import Maybe exposing (withDefault)
import Table exposing (Column, HtmlDetails, Status(..), increasingOrDecreasingBy, veryCustomColumn)
import View.Tooltips exposing (tooltip)


stringColumnWithAttributes : String -> List (Attribute msg) -> (data -> String) -> Column data msg
stringColumnWithAttributes name attributes formatter =
    veryCustomColumn
        { name = name
        , viewData =
            \stream ->
                HtmlDetails attributes
                    [ text (formatter stream) ]
        , sorter = increasingOrDecreasingBy formatter
        }


{-| The code below is heavily based on the original
<https://github.com/NoRedInk/elm-sortable-table/> code, whose license
can be found in the `/client/third_party/` directory of this project.
-}
infoThead :
    (String -> Maybe String)
    -> List ( String, Status, Attribute msg )
    -> Table.HtmlDetails msg
infoThead lookupTooltip headers =
    Table.HtmlDetails [] (List.map (infoTheadHelp lookupTooltip) headers)


infoTheadHelp :
    (String -> Maybe String)
    -> ( String, Status, Attribute msg )
    -> Html msg
infoTheadHelp lookupTooltip ( name, status, onClick_ ) =
    let
        content =
            case status of
                Unsortable ->
                    [ Html.text name ]

                Sortable selected ->
                    [ Html.text name
                    , if selected then
                        darkGrey "↓"

                      else
                        lightGrey "↓"
                    ]

                Reversible Nothing ->
                    [ Html.text name
                    , lightGrey "↕"
                    ]

                Reversible (Just isReversed) ->
                    [ Html.text name
                    , darkGrey
                        (if isReversed then
                            "↑"

                         else
                            "↓"
                        )
                    ]

        mTooltip =
            lookupTooltip name
                |> Maybe.map (\tooltipContent -> [ tooltip tooltipContent ])
                |> withDefault []
    in
    Html.th [ onClick_ ] (content ++ mTooltip)


darkGrey : String -> Html msg
darkGrey symbol =
    Html.span [ style "color" "#555" ] [ Html.text (" " ++ symbol) ]


lightGrey : String -> Html msg
lightGrey symbol =
    Html.span [ style "color" "#ccc" ] [ Html.text (" " ++ symbol) ]
