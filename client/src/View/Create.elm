module View.Create exposing (view)

import Browser exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Route exposing (routeToString)
import Types exposing (..)
import UIKit
import Url exposing (..)


view : Model -> Html msg
view model =
    div [ class "create-pane" ]
        [ h2 [] [ text "Data Product Creation" ]
        , p [] [ text "There are many ways to create a data product. An application may create a data product from user inputs, from REST calls, event streams, other sources, or a combination of inputs. The application code and frameworks that can be used to build data products varies just as widely, from monoliths, to microservices, to batch and streaming jobs." ]
        , p [] [ text "In this demo, we’re showcasing creating new data products using existing data products in the form of event streams." ]
        , p [] [ text "The following example shows the creation of a new ksqlDB application, output Kafka topic, and event schema. The application joins the pageviews and users together, enriching the output into a new Kafka topic." ]
        , p [] [ text "Click the button to go to Confluent Cloud, where this query will be pre-populated. Create the application and return to this screen." ]
        ]
