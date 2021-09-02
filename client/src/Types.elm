module Types exposing
    ( Flags
    , Model
    , Msg(..)
    , View(..)
    )

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav exposing (Key)


type alias Flags =
    String


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
    , logoPath : String
    , activeView : View
    }
