module GenericDict.Extra exposing
    ( fromListBy
    , optional
    )

import GenericDict as Dict exposing (Dict)
import Monocle.Optional exposing (Optional)


fromListBy : (a -> k) -> (k -> String) -> List a -> Dict k a
fromListBy keyFn keyStr =
    List.map (\x -> ( keyFn x, x ))
        >> Dict.fromList keyStr


optional : (k -> String) -> k -> Optional (Dict k v) v
optional keyStr key =
    { getOption = Dict.get keyStr key
    , set = Dict.insert keyStr key
    }
