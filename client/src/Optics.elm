module Optics exposing (..)

{-| Optics are composable getters and setters, for peeking into values and/or changing their values.
-}

import GenericDict as Dict exposing (Dict)
import GenericDict.Extra as Dict
import Monocle.Common
import Monocle.Compose exposing (..)
import Monocle.Lens exposing (..)
import Monocle.Optional exposing (..)
import RemoteData exposing (WebData)
import Types exposing (..)


webDataProducts : Lens Model (WebData (Dict QualifiedName DataProduct))
webDataProducts =
    Lens .dataProducts (\a s -> { s | dataProducts = a })


isPublished : Lens { s | isPublished : a } a
isPublished =
    Lens .isPublished (\a s -> { s | isPublished = a })


qualifiedName : Lens QualifiedName String
qualifiedName =
    Lens unQualifiedName (\str _ -> QualifiedName str)


dataProductPublished : QualifiedName -> Optional Model (WebData Bool)
dataProductPublished name =
    webDataProducts
        |> lensWithPrism RemoteData.prism
        |> optionalWithOptional (Dict.optional unQualifiedName name)
        |> optionalWithLens isPublished
