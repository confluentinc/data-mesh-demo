module Result.Extras exposing (isErr)


isErr : Result e a -> Bool
isErr x =
    case x of
        Ok _ ->
            False

        Err _ ->
            True
