module RemoteData.Extra exposing (mapOnSuccess)

import RemoteData exposing (RemoteData(..))


{-| Like `RemoteData.map2`, but if either value is not Successful, returns the second argument untouched.
-}
mapOnSuccess : (a -> b -> b) -> RemoteData e a -> RemoteData e b -> RemoteData e b
mapOnSuccess fn webResult =
    RemoteData.map
        (case webResult of
            Success result ->
                fn result

            _ ->
                identity
        )
