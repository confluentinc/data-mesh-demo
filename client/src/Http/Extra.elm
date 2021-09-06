module Http.Extra exposing (delete)

import Http exposing (Body, Expect, emptyBody, request)


delete :
    { url : String
    , expect : Expect msg
    }
    -> Cmd msg
delete r =
    request
        { method = "DELETE"
        , headers = []
        , url = r.url
        , body = emptyBody
        , expect = r.expect
        , timeout = Nothing
        , tracker = Nothing
        }
