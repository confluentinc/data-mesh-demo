module UIKit exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (class)


container : Attribute msg
container =
    class "uk-container"


tab : Attribute msg
tab =
    class "uk-tab"


table : Attribute msg
table =
    class "uk-table"


tableDivider : Attribute msg
tableDivider =
    class "uk-table-divider"


tableStriped : Attribute msg
tableStriped =
    class "uk-table-striped"


tableSmall : Attribute msg
tableSmall =
    class "uk-table-small"


formHorizontal : Attribute msg
formHorizontal =
    class "uk-form-horizontal"


formLabel : Attribute msg
formLabel =
    class "uk-form-label"


input : Attribute msg
input =
    class "uk-input"


formControls : Attribute msg
formControls =
    class "uk-form-controls"


formInput : Attribute msg
formInput =
    class "uk-input"


formControlsText : Attribute msg
formControlsText =
    class "uk-form-controls-text"


button : Attribute msg
button =
    class "uk-button"


buttonGroup : Attribute msg
buttonGroup =
    class "uk-button-group"


buttonPrimary : Attribute msg
buttonPrimary =
    class "uk-button-primary"


buttonDefault : Attribute msg
buttonDefault =
    class "uk-button-default"


margin : Attribute msg
margin =
    class "uk-margin"
