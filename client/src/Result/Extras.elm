module Result.Extras exposing (isErr)


isErr x =
    case x of
        Ok _ ->
            False

        Err _ ->
            True
