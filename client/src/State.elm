module State exposing (..)

import Browser exposing (..)
import Browser.Navigation as Nav exposing (Key)
import Dialog.Common as Dialog
import GenericDict as Dict exposing (Dict)
import Html exposing (..)
import Monocle.Optional as Optional
import Optics
import RemoteData exposing (RemoteData(..), WebData)
import RemoteData.Extra exposing (mapOnSuccess)
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
      , streams = Loading
      , activeStreamKey = Nothing
      , publishModel = Nothing
      , deleteResult = NotAsked
      }
    , Rest.getStreams
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

        GotStreams newStreams ->
            ( { model | streams = newStreams }
            , Cmd.none
            )

        SelectStream qualifiedName ->
            ( { model
                | activeStreamKey =
                    if model.activeStreamKey == Just qualifiedName then
                        Nothing

                    else
                        Just qualifiedName
              }
            , Cmd.none
            )

        StartPublishDialog qualifiedName ->
            let
                topic : Maybe Topic
                topic =
                    (Optics.streamTopic qualifiedName).getOption model

                dialog : Maybe PublishModel
                dialog =
                    case topic of
                        Just t ->
                            Just
                                { topic = t
                                , owner = ""
                                , description = ""
                                }

                        Nothing ->
                            Nothing
            in
            ( { model | publishModel = dialog }
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

        DataProductPublished result ->
            ( { model
                | publishModel = Nothing
                , streams =
                    mapOnSuccess
                        (\newDataProduct dict ->
                            Dict.insert unQualifiedName
                                newDataProduct.qualifiedName
                                (StreamDataProduct newDataProduct)
                                dict
                        )
                        result
                        model.streams
              }
            , Cmd.none
            )

        DeleteDataProduct qualifiedName ->
            ( { model | deleteResult = Loading }
            , Rest.deleteDataProduct qualifiedName
            )

        DataProductDeleted result ->
            ( { model
                | deleteResult = result
                , streams =
                    mapOnSuccess
                        (\key ->
                            Dict.update unQualifiedName
                                key
                                (Maybe.map unpublishStream)
                        )
                        result
                        model.streams
              }
            , Cmd.none
            )


unpublishStream : Stream -> Stream
unpublishStream old =
    case old of
        StreamTopic t ->
            StreamTopic t

        StreamDataProduct d ->
            StreamTopic
                { qualifiedName = d.qualifiedName
                , name = d.name
                }


updatePublishModel : PublishDialogMsg -> PublishModel -> ( PublishModel, Cmd Msg )
updatePublishModel msg model =
    case msg of
        PublishDialogSetOwner newOwner ->
            ( { model | owner = newOwner }, Cmd.none )

        PublishDialogSetDescription newDescription ->
            ( { model | description = newDescription }, Cmd.none )
