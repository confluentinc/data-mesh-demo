module Optics exposing (..)

import Dict exposing (Dict)
import Monocle.Common exposing (..)
import Monocle.Compose exposing (..)
import Monocle.Lens exposing (..)
import Monocle.Optional exposing (..)
import RemoteData exposing (WebData)
import Types exposing (..)


webDataProducts : Lens Model (WebData (Dict String DataProduct))
webDataProducts =
    Lens .dataProducts (\a s -> { s | dataProducts = a })


isPublished : Lens { s | isPublished : a } a
isPublished =
    Lens .isPublished (\a s -> { s | isPublished = a })


dataProductPublished : String -> Optional Model (WebData Bool)
dataProductPublished qualifiedName =
    webDataProducts
        |> lensWithPrism RemoteData.prism
        |> optionalWithOptional (dict qualifiedName)
        |> optionalWithLens isPublished
