module Table.Extras exposing (stringColumnWithAttributes)

import Html exposing (Attribute, text)
import Table exposing (Column, HtmlDetails, defaultCustomizations, increasingOrDecreasingBy, stringColumn, veryCustomColumn)


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
