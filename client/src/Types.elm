module Types exposing (..)

import Array exposing (Array)
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import GenericDict exposing (Dict)
import Json.Encode as Encode
import RemoteData exposing (RemoteData, WebData)
import Stomp exposing (AuditLogMsg)
import Stomp.Client as Stomp
import Table
import Url as Url exposing (Url)


type alias Model =
    { navKey : Nav.Key
    , flags : Flags
    , activeView : View
    , stompSession : Stomp.Session Stomp.Msg
    , auditLogMsgs : Array (Result String AuditLogMsg)
    , dataProductsTableState : Table.State
    , streams : WebData (Dict QualifiedName Stream)
    , useCases : WebData (Dict String UseCase)
    , publishForm : Maybe PublishForm
    , publishFormResult : WebData DataProduct
    , deleteResult : WebData QualifiedName
    }


type alias PublishForm =
    { topic : Topic
    , domain : String
    , owner : String
    , description : String
    , quality : ProductQuality
    , sla : ProductSla
    }


type ProductQuality
    = Authoritative
    | Curated
    | Raw
    | OtherQuality String


allProductQualities : List ProductQuality
allProductQualities =
    [ Authoritative
    , Curated
    , Raw
    ]


type ProductSla
    = Tier1
    | Tier2
    | Tier3
    | OtherSla String


allProductSlas : List ProductSla
allProductSlas =
    [ Tier1
    , Tier2
    , Tier3
    ]


type alias Flags =
    { hostedMode : Bool
    , images :
        { logo : String
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
      --
    | StompMsg Stomp.Msg
      --
    | SetDataProductsTableState Table.State
      --
    | GotStreams (WebData (Dict QualifiedName Stream))
    | GotUseCases (WebData (Dict String UseCase))
      --
    | StartPublishDialog QualifiedName
    | PublishFormMsg PublishFormMsg
    | PublishDataProduct PublishForm
    | DataProductPublished (WebData PublishFormResult)
    | AbandonPublishDialog
      --
    | DeleteDataProduct QualifiedName
    | DataProductDeleted (WebData QualifiedName)


type PublishFormMsg
    = PublishFormSetOwner String
    | PublishFormSetDescription String
    | PublishFormSetDomain String
    | PublishFormSetQuality ProductQuality
    | PublishFormSetSla ProductSla


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
    , domain : String
    , description : String
    , owner : String
    , urls : DataProductUrls
    , schema : KsqlSchema
    , quality : ProductQuality
    , sla : ProductSla
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
    , ksqlDbLaunchUrl : Url
    , outputTopic : String
    }


streamQualifiedName : Stream -> QualifiedName
streamQualifiedName stream =
    case stream of
        StreamTopic t ->
            t.qualifiedName

        StreamDataProduct p ->
            p.qualifiedName
