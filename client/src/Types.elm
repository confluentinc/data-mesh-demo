module Types exposing (..)

import Array exposing (Array)
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import GenericDict exposing (Dict)
import RemoteData exposing (WebData)
import Set exposing (Set)
import Stomp exposing (AuditLogMsg)
import Stomp.Client as Stomp
import Table
import Url exposing (Url)
import Validate exposing (Validator, ifTrue)


type alias Model =
    { navKey : Nav.Key
    , flags : Flags
    , actuatorInfo : WebData ActuatorInfo
    , activeView : View
    , activeScreenshot : Maybe ScreenshotTarget
    , stompSession : Stomp.Session Stomp.Msg
    , auditLogModel : AuditLogModel
    , dataProductsTableState : Table.State
    , streams : WebData (Dict QualifiedName Stream)
    , useCases : WebData (Dict UseCaseName UseCase)
    , publishForm : Maybe PublishForm
    , publishFormResult : WebData DataProduct
    , deleteConfirmation : Maybe DataProduct
    , deleteResult : WebData QualifiedName
    , executeUseCaseResult : WebData UseCaseName
    }


type alias AuditLogModel =
    { minimised : Bool
    , messages : Array (Result String AuditLogMsg)
    }


type ScreenshotTarget
    = ExportScreenshot
    | SchemaScreenshot
    | TopicScreenshot
    | LineageScreenshot
    | SearchScreenshot


type alias PublishForm =
    { topic : Topic
    , domain : String
    , owner : String
    , description : String
    , quality : ProductQuality
    , sla : ProductSla
    }


type PublishFormError
    = RestrictedOwner


restrictedOwners : Set String
restrictedOwners =
    Set.fromList [ "@edge-team" ]


publishFormValidator : Validator PublishFormError PublishForm
publishFormValidator =
    Validate.all
        [ ifTrue (\form -> Set.member form.owner restrictedOwners) RestrictedOwner
        ]


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
    { staticImages : StaticImages
    }


type alias StaticImages =
    { logoPath : String
    , exportScreenshotPath : String
    , schemaScreenshotPath : String
    , topicScreenshotPath : String
    , lineageScreenshotPath : String
    , searchScreenshotPath : String
    }


type View
    = Discover (Maybe QualifiedName)
    | Create (Maybe UseCaseName)
    | Manage
    | NotFound


isSameTab : View -> View -> Bool
isSameTab a b =
    case ( a, b ) of
        ( Discover _, Discover _ ) ->
            True

        ( Create _, Create _ ) ->
            True

        ( Manage, Manage ) ->
            True

        ( NotFound, NotFound ) ->
            True

        _ ->
            False


type Msg
    = NoOp
    | ChangeUrl UrlRequest
    | ChangeView View
    | ToggleAuditMinimised
      --
    | StompMsg Stomp.Msg
      --
    | ShowScreenshot ScreenshotTarget
    | ClearScreenshot
      --
    | SetDataProductsTableState Table.State
      --
    | GotStreams (WebData (Dict QualifiedName Stream))
    | GotUseCases (WebData (Dict UseCaseName UseCase))
    | GotActuatorInfo (WebData ActuatorInfo)
      --
    | StartPublishDialog QualifiedName
    | PublishFormMsg PublishFormMsg
    | PublishDataProduct PublishForm
    | DataProductPublished (WebData PublishFormResult)
    | AbandonPublishDialog
      --
    | DeleteDataProduct QualifiedName
    | AbandonDeleteDataProduct
    | ConfirmDeleteDataProduct QualifiedName
    | DataProductDeleted (WebData QualifiedName)
      --
    | ExecuteUseCase UseCaseName
    | UseCaseExecuted (WebData UseCaseName)


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


type UseCaseName
    = UseCaseName String


unUseCaseName : UseCaseName -> String
unUseCaseName (UseCaseName str) =
    str


type alias UseCase =
    { name : UseCaseName
    , description : String
    , inputs : String
    , ksqlDbCommand : String
    , ksqlDbLaunchUrl : Url
    , outputTopic : String
    }


type alias ActuatorInfo =
    { hostedMode : HostedMode
    , domain : String
    , commitId : String
    }


type HostedMode
    = Hosted
    | Local


streamQualifiedName : Stream -> QualifiedName
streamQualifiedName stream =
    case stream of
        StreamTopic t ->
            t.qualifiedName

        StreamDataProduct p ->
            p.qualifiedName


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
