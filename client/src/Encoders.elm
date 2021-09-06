module Encoders exposing (encodePublishModel)

import Json.Encode as Encode exposing (..)
import RemoteData exposing (RemoteData(..))
import Types exposing (..)
import Url as Url exposing (Url)


encodePublishModel : PublishModel -> Value
encodePublishModel publishModel =
    object
        [ ( "@type", string "TOPIC" )
        , ( "qualifiedName", qualifiedName publishModel.qualifiedName )
        , ( "dataProductTag"
          , object
                [ ( "owner", string publishModel.owner )
                , ( "description", string publishModel.description )
                ]
          )
        ]


qualifiedName : QualifiedName -> Value
qualifiedName =
    unQualifiedName >> string
