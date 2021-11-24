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


formDanger : Attribute msg
formDanger =
    class "uk-form-danger"


fieldset : Attribute msg
fieldset =
    class "uk-fieldset"


input : Attribute msg
input =
    class "uk-input"


checkbox : Attribute msg
checkbox =
    class "uk-checkbox"


radio : Attribute msg
radio =
    class "uk-radio"


select : Attribute msg
select =
    class "uk-select"


textarea : Attribute msg
textarea =
    class "uk-textarea"


formControls : Attribute msg
formControls =
    class "uk-form-controls"


formControlsText : Attribute msg
formControlsText =
    class "uk-form-controls-text"


formInput : Attribute msg
formInput =
    class "uk-input"


button : Attribute msg
button =
    class "uk-button"


buttonSmall : Attribute msg
buttonSmall =
    class "uk-button-small"


buttonGroup : Attribute msg
buttonGroup =
    class "uk-button-group"


buttonPrimary : Attribute msg
buttonPrimary =
    class "uk-button-primary"


buttonSecondary : Attribute msg
buttonSecondary =
    class "uk-button-secondary"


buttonDefault : Attribute msg
buttonDefault =
    class "uk-button-default"


buttonDanger : Attribute msg
buttonDanger =
    class "uk-button-danger"


buttonLink : Attribute msg
buttonLink =
    class "uk-button-link"


margin : Attribute msg
margin =
    class "uk-margin"


marginBottom : Attribute msg
marginBottom =
    class "uk-margin-bottom"


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


grid : Attribute msg
grid =
    class "uk-grid"


textDanger : Attribute msg
textDanger =
    class "uk-text-danger"


width_1_1 : Attribute msg
width_1_1 =
    class "uk-width-1-1"


width_1_2 : Attribute msg
width_1_2 =
    class "uk-width-1-2"


width_1_3 : Attribute msg
width_1_3 =
    class "uk-width-1-3"


width_2_3 : Attribute msg
width_2_3 =
    class "uk-width-2-3"


width_1_4 : Attribute msg
width_1_4 =
    class "uk-width-1-4"


width_1_5 : Attribute msg
width_1_5 =
    class "uk-width-1-5"


width_4_5 : Attribute msg
width_4_5 =
    class "uk-width-4-5"


width_2_5 : Attribute msg
width_2_5 =
    class "uk-width-2-5"


width_1_6 : Attribute msg
width_1_6 =
    class "uk-width-1-6"


width_5_6 : Attribute msg
width_5_6 =
    class "uk-width-5-6"


width_1_7 : Attribute msg
width_1_7 =
    class "uk-width-1-7"


width_2_7 : Attribute msg
width_2_7 =
    class "uk-width-2-7"


width_1_10 : Attribute msg
width_1_10 =
    class "uk-width-1-10"


width_2_10 : Attribute msg
width_2_10 =
    width_1_5


childWidth_1_6 : Attribute msg
childWidth_1_6 =
    class "uk-child-width-1-6"


childWidthAuto : Attribute msg
childWidthAuto =
    class "uk-child-width-auto"


childWidthExpand : Attribute msg
childWidthExpand =
    class "uk-child-width-expand"
