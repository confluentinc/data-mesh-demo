module View.Landing exposing (view)

import Html exposing (..)
import Html.Attributes exposing (href, src, style)
import Types exposing (..)
import UIKit

view : Model -> Html Msg

view model = div []
                 [ h2 [][ text "The Data Mesh"]
                 , p [] [ text "Visit our Data Mesh blog post for more information <TODO - Link to Blog>"]
                 , p [] [ text "This proof-of-concept application showcases a self-serve data mesh UI, for use by both consumers and producers of data products."]
                 , p [] [
                        strong [] [ text "NOTE:" ]
                        , text "You are using the hosted version of this application. Not all Confluent Cloud functionality will be available to you."
                        , li [] [ a [ href "https://github.com/confluentinc/data-mesh-demo/blob/main/README.md#running-locally" ]
                        [ text "Try using the locally-hosted version for full functionality." ] ]
                        ]
                 , p [] [ h3 [] [text "Consumers"]]
                 , p [] [
                     li [] [text "Tab 1: Data Product consumers can find the data products that they need"],
                     li [] [text "Tab 2: Build an application to use them"],
                     li [] [text "Tab 3: And optionally publish any output event streams as a new data product"]
                     ]
                 , p [] [img [ UIKit.width_2_3, src model.flags.staticImages.landingImage1Path] []]
                 , p [] [text "While we use ksqlDB in this proof-of-concept application, you are free to build your application using any technology."]
                 , p [] [img [ UIKit.width_2_3, src model.flags.staticImages.landingImage2Path] []]
                 , p [] [h3 [] [text "Producers"]]
                 , p [] [text "Event Streams, including those sourced via Kafka Connect, can be managed as data products in Tab 3. As the data product owner, you can choose streams within your domain to expose as data products for others to use."]
                 , p [] [img [ UIKit.width_2_3, src model.flags.staticImages.landingImage3Path] []]
                 ]
