module Encoders exposing (encodePublishForm)

import Json.Encode as Encode exposing (..)
import RemoteData exposing (RemoteData(..))
import Types exposing (..)
import Url as Url exposing (Url)


encodePublishForm : PublishForm -> Value
encodePublishForm publishForm =
    object
        [ ( "@type", string "TOPIC" )
        , ( "qualifiedName", qualifiedName publishForm.topic.qualifiedName )
        , ( "dataProductTag"
          , object
                [ ( "owner", string publishForm.owner )
                , ( "description", string publishForm.description )
                ]
          )
        ]


qualifiedName : QualifiedName -> Value
qualifiedName =
    unQualifiedName >> string
