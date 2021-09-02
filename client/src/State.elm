module State exposing (..)

import Browser exposing (..)
import Browser.Navigation as Nav exposing (Key)
import Html exposing (..)
import Route exposing (routeParser)
import Types exposing (..)
import Url exposing (..)


initialModel : Key -> Model
initialModel key =
    { key = key
    , activeView = Discover
    , n = 6
    }


init : flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    ( initialModel key, Cmd.none )


onUrlChange : Url -> Msg
onUrlChange _ =
    NoOp


onUrlRequest : UrlRequest -> Msg
onUrlRequest =
    ChangeView


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ChangeView urlRequest ->
            case urlRequest of
                Internal url ->
                    ( { model | activeView = routeParser url }
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )
