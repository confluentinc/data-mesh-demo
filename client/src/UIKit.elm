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


tableHover : Attribute msg
tableHover =
    class "uk-table-hover"


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


textarea : Attribute msg
textarea =
    class "uk-textarea"


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


buttonDanger : Attribute msg
buttonDanger =
    class "uk-button-danger"


margin : Attribute msg
margin =
    class "uk-margin"


alert : Attribute msg
alert =
    class "uk-alert"


alertWarning : Attribute msg
alertWarning =
    class "uk-alert-warning"


alertDanger : Attribute msg
alertDanger =
    class "uk-alert-danger"


active : Attribute msg
active =
    class "uk-active"


modalTitle : Attribute msg
modalTitle =
    class "uk-modal-title"


modalClose : Attribute msg
modalClose =
    class "uk-modal-close"
