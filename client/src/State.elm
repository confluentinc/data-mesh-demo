module State exposing (..)

import Browser exposing (..)
import Browser.Navigation as Nav exposing (Key)
import Dialog.Common as Dialog
import GenericDict exposing (Dict)
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
      , publishModel = Nothing
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

        StartPublishDialog qualifiedName ->
            let
                dataProduct : Maybe DataProduct
                dataProduct =
                    (Optics.dataProduct qualifiedName).getOption model

                dialog =
                    case dataProduct of
                        Just product ->
                            { qualifiedName = qualifiedName
                            , name = product.name
                            , description = product.description
                            }

                        Nothing ->
                            { qualifiedName = qualifiedName
                            , name = ""
                            , description = ""
                            }
            in
            ( { model | publishModel = Just dialog }
            , Cmd.none
            )

        AbandonPublishDialog ->
            ( { model | publishModel = Nothing }
            , Cmd.none
            )

        PublishDialogMsg subMsg ->
            case model.publishModel of
                Nothing ->
                    ( model, Cmd.none )

                Just publishModel ->
                    let
                        ( subModel, subCmd ) =
                            updatePublishModel subMsg publishModel
                    in
                    ( { model | publishModel = Just subModel }
                    , subCmd
                    )

        PublishDataProduct publishModel ->
            ( model
            , Rest.publishDataProduct publishModel
            )

        DataProductPublished publishModel ->
            ( { model | publishModel = Nothing }
                |> (Optics.dataProductPublished publishModel.qualifiedName).set (Success True)
            , Cmd.none
            )


updatePublishModel : PublishDialogMsg -> PublishModel -> ( PublishModel, Cmd Msg )
updatePublishModel msg model =
    case msg of
        PublishDialogSetName newName ->
            ( { model | name = newName }, Cmd.none )

        PublishDialogSetDescription newDescription ->
            ( { model | description = newDescription }, Cmd.none )
