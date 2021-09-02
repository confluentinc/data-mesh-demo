module Types exposing
    ( DataProduct
    , DataProductUrls
    , Flags
    , Model
    , Msg(..)
    , QualifiedName
    , View(..)
    , unQualifiedName
    )

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav exposing (Key)
import Dict exposing (Dict)
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
    | GotDataProducts (WebData (Dict QualifiedName DataProduct))
    | SelectDataProduct QualifiedName
    | PublishDataProduct QualifiedName


type alias Model =
    { key : Key
    , logoPath : String
    , activeView : View
    , dataProductsTableState : Table.State
    , dataProducts : WebData (Dict QualifiedName DataProduct)
    , activeDataProductKey : Maybe QualifiedName
    }



-- | See src/main/java/io/confluent/demo/datamesh/cc/urls/api/UrlService.java


type alias DataProductUrls =
    { schemaUrl : Url
    , portUrl : Url
    , lineageUrl : Url
    }


type alias QualifiedName =
    String


unQualifiedName : QualifiedName -> String
unQualifiedName str =
    str


type alias DataProduct =
    , qualifiedName : QualifiedName
    , name : String
    , description : String
    , owner : String
    , urls : DataProductUrls
    }
