module Types exposing
    ( DataProduct
    , DataProductUrls
    , Flags
    , KsqlSchema
    , Model
    , Msg(..)
    , PublishForm
    , PublishFormMsg(..)
    , PublishFormResult
    , QualifiedName(..)
    , Stream(..)
    , Topic
    , UseCase
    , View(..)
    , streamQualifiedName
    , unQualifiedName
    )

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav exposing (Key)
import GenericDict exposing (Dict)
import Json.Encode as Encode
import RemoteData exposing (WebData)
import Table
import Url as Url exposing (Url)


type alias Model =
    { key : Key
    , flags : Flags
    , activeView : View
    , dataProductsTableState : Table.State
    , streams : WebData (Dict QualifiedName Stream)
    , useCases : WebData (Dict String UseCase)
    , publishForm : Maybe PublishForm
    , publishFormResult : WebData DataProduct
    , deleteResult : WebData QualifiedName
    }


type alias PublishForm =
    { topic : Topic
    , owner : String
    , description : String
    }


type alias Flags =
    { images :
        { logo :
            String
        }
    }


type View
    = Discover (Maybe QualifiedName)
    | Create (Maybe String)
    | Manage
    | NotFound


type Msg
    = NoOp
    | ChangeUrl UrlRequest
    | ChangeView View
    | SetDataProductsTableState Table.State
    | GotStreams (WebData (Dict QualifiedName Stream))
    | GotUseCases (WebData (Dict String UseCase))
    | StartPublishDialog QualifiedName
    | PublishFormMsg PublishFormMsg
    | PublishDataProduct PublishForm
    | DataProductPublished (WebData PublishFormResult)
    | DeleteDataProduct QualifiedName
    | DataProductDeleted (WebData QualifiedName)
    | AbandonPublishDialog


type PublishFormMsg
    = PublishFormSetOwner String
    | PublishFormSetDescription String


type alias PublishFormResult =
    DataProduct



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
    , schema : KsqlSchema
    }


type alias Topic =
    { qualifiedName : QualifiedName
    , name : String
    }


type alias DataProductUrls =
    { schemaUrl : Url
    , portUrl : Url
    , lineageUrl : Url
    , exportUrl : Url
    }


type alias KsqlSchema =
    { subject : String
    , version : Int
    , id : Int
    , schema : String
    }


type alias UseCase =
    { description : String
    , name : String
    , inputs : String
    , ksqlDbCommand : String
    , outputTopic : String
    }


streamQualifiedName : Stream -> QualifiedName
streamQualifiedName stream =
    case stream of
        StreamTopic t ->
            t.qualifiedName

        StreamDataProduct p ->
            p.qualifiedName
