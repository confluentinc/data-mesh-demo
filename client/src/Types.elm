module Types exposing (Model, Msg(..), View(..))

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav exposing (Key)


type View
    = Discover
    | Create
    | Manage
    | NotFound


type Msg
    = NoOp
    | ChangeView UrlRequest


type alias Model =
    { key : Key
    , activeView : View
    , n : Int
    }
