module Types exposing
    ( DataProduct
    , DataProductUrls
    , Flags
    , Model
    , Msg(..)
    , PublishDialogMsg(..)
    , PublishModel
    , QualifiedName(..)
    , Stream(..)
    , Topic
    , View(..)
    , streamQualifiedName
    , unQualifiedName
    )

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav exposing (Key)
import GenericDict exposing (Dict)
import RemoteData exposing (WebData)
import Table
import Url as Url exposing (Url)


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
    | SetDataProductsTableState Table.State
    | GotStreams (WebData (Dict QualifiedName Stream))
    | SelectStream QualifiedName
    | StartPublishDialog QualifiedName
    | PublishDialogMsg PublishDialogMsg
    | PublishDataProduct PublishModel
    | DataProductPublished (WebData DataProduct)
    | DeleteDataProduct QualifiedName
    | DataProductDeleted (WebData QualifiedName)
    | AbandonPublishDialog


type PublishDialogMsg
    = PublishDialogSetOwner String
    | PublishDialogSetDescription String


type alias Model =
    { key : Key
    , logoPath : String
    , activeView : View
    , dataProductsTableState : Table.State
    , streams : WebData (Dict QualifiedName Stream)
    , activeStreamKey : Maybe QualifiedName
    , publishModel : Maybe PublishModel
    , deleteResult : WebData QualifiedName
    }


type alias PublishModel =
    { topic : Topic
    , owner : String
    , description : String
    }



-- | See src/main/java/io/confluent/demo/datamesh/cc/urls/api/UrlService.java


type QualifiedName
    = QualifiedName String


unQualifiedName : QualifiedName -> String
unQualifiedName (QualifiedName str) =
    str


type Stream
    = StreamDataProduct DataProduct
    | StreamTopic Topic


type alias DataProduct =
    { qualifiedName : QualifiedName
    , name : String
    , description : String
    , owner : String
    , urls : DataProductUrls
    }


type alias Topic =
    { qualifiedName : QualifiedName
    , name : String
    }


type alias DataProductUrls =
    { schemaUrl : Url
    , portUrl : Url
    , lineageUrl : Url
    }


streamQualifiedName : Stream -> QualifiedName
streamQualifiedName stream =
    case stream of
        StreamTopic t ->
            t.qualifiedName

        StreamDataProduct p ->
            p.qualifiedName
