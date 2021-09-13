module State exposing (..)

import Browser exposing (..)
import Browser.Navigation as Nav
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


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    ( { navKey = navKey
      , flags = flags
      , activeView = routeParser url
      , dataProductsTableState = Table.initialSort "name"
      , streams = Loading
      , useCases = Loading
      , publishForm = Nothing
      , publishFormResult = NotAsked
      , deleteResult = NotAsked
      }
    , Cmd.batch
        [ Rest.getStreams
        , Rest.getUseCases
        ]
    )


onUrlChange : Url -> Msg
onUrlChange _ =
    NoOp


onUrlRequest : UrlRequest -> Msg
onUrlRequest =
    ChangeUrl


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

        ChangeUrl urlRequest ->
            case urlRequest of
                Internal url ->
                    update (ChangeView (routeParser url)) model

                External url ->
                    ( model
                    , Nav.load url
                    )

        ChangeView view ->
            ( { model | activeView = view }
            , Nav.pushUrl model.navKey (Route.routeToString view)
            )

        GotStreams newStreams ->
            ( { model | streams = newStreams }
            , Cmd.none
            )

        GotUseCases newUseCases ->
            ( { model | useCases = newUseCases }
            , Cmd.none
            )

        StartPublishDialog qualifiedName ->
            let
                topic : Maybe Topic
                topic =
                    (Optics.streamTopic qualifiedName).getOption model

                dialog : Maybe PublishForm
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
            ( { model
                | publishForm = dialog
                , publishFormResult = NotAsked
              }
            , Cmd.none
            )

        AbandonPublishDialog ->
            ( { model
                | publishForm = Nothing
                , publishFormResult = NotAsked
              }
            , Cmd.none
            )

        PublishFormMsg subMsg ->
            case model.publishForm of
                Nothing ->
                    ( model, Cmd.none )

                Just publishForm ->
                    let
                        ( subModel, subCmd ) =
                            updatePublishForm subMsg publishForm
                    in
                    ( { model | publishForm = Just subModel }
                    , subCmd
                    )

        PublishDataProduct publishForm ->
            ( { model
                | publishFormResult = Loading
              }
            , Rest.publishDataProduct publishForm
            )

        DataProductPublished (Success newDataProduct) ->
            ( { model
                | publishForm = Nothing
                , publishFormResult = NotAsked
                , streams =
                    RemoteData.map
                        (Dict.insert unQualifiedName
                            newDataProduct.qualifiedName
                            (StreamDataProduct newDataProduct)
                        )
                        model.streams
              }
            , Cmd.none
            )

        DataProductPublished result ->
            ( { model
                | publishFormResult = result
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


updatePublishForm : PublishFormMsg -> PublishForm -> ( PublishForm, Cmd Msg )
updatePublishForm msg model =
    case msg of
        PublishFormSetOwner newOwner ->
            ( { model | owner = newOwner }, Cmd.none )

        PublishFormSetDescription newDescription ->
            ( { model | description = newDescription }, Cmd.none )
