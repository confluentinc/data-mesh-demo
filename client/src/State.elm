module State exposing (..)

import Browser exposing (..)
import Browser.Navigation as Nav exposing (Key)
import Dict exposing (Dict)
import Html exposing (..)
import Optics
import RemoteData exposing (RemoteData(..), WebData)
import Rest
import Route exposing (routeParser)
import Table
import Types exposing (..)
import Url exposing (..)


init : String -> Url -> Key -> ( Model, Cmd Msg )
init logoPath url key =
    ( { key = key
      , logoPath = logoPath
      , activeView = routeParser url
      , dataProductsTableState = Table.initialSort "name"
      , dataProducts = Loading
      , activeDataProductKey = Nothing
      }
    , Rest.getDataProducts
    )


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

        SetDataProductsTableState newTableState ->
            ( { model | dataProductsTableState = newTableState }
            , Cmd.none
            )

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

        GotDataProducts newDataProducts ->
            ( { model | dataProducts = newDataProducts }
            , Cmd.none
            )

        SelectDataProduct qualifiedName ->
            ( { model
                | activeDataProductKey =
                    if model.activeDataProductKey == Just qualifiedName then
                        Nothing

                    else
                        Just qualifiedName
              }
            , Cmd.none
            )

        PublishDataProduct qualifiedName ->
            ( (Optics.dataProductPublished qualifiedName).set (Success True) model
            , Rest.publishDataProduct qualifiedName
            )
