port module Scrolling exposing (scrollToBottom)


type alias ElementId =
    String


port scrollToBottom : ElementId -> Cmd msg
