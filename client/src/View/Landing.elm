module View.Landing exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, src)
import Markdown
import Types exposing (..)


view : StaticImages -> Html Msg
view images =
    div [ class "landing-pane" ]
        [ Markdown.toHtml [] landingIntro
        , img
            [ class "landing-diagram"
            , src images.landingImage1Path
            ]
            []
        ]


landingIntro : String
landingIntro =
    """
## The Data Mesh

This prototype application showcases a self-serve Data Mesh UI, for use by both consumers and producers of
data products. The companion [Data Mesh blog post](https://www.confluent.io/blog/) goes into more details on
Data Mesh concepts and how to use this prototype.

**NOTE:** You are using the hosted version of this application, not all of the application's functionality
is available. If you'd like to run a full featured version connected to your own Confluent Cloud account,
instructions for
[running a locally hosted version are available](https://github.com/confluentinc/data-mesh-demo/blob/main/README.md#running-locally)

This prototype is organized by steps you might take to consume and produce data products:

* Tab 1 Is for Data Product consumers, where they can explore data products available including the metadata that
describes them
* Tab 2 Is for Application Developers who can use available data products to build new
applications
* Tab 3 Is for Data Product owners, who can manage what published data products and their advertised metadata
"""
