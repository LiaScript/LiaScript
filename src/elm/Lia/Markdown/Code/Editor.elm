module Lia.Markdown.Code.Editor exposing
    ( annotations
    , editor
    , enableBasicAutocompletion
    , enableLiveAutocompletion
    , enableSnippets
    , extensions
    , highlightActiveLine
    , maxLines
    , mode
    , onChange
    , readOnly
    , showCursor
    , showGutter
    , showPrintMargin
    , tabSize
    , theme
    , useSoftTabs
    , useWrapMode
    , value
    )

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
import Json.Decode as JD
import Json.Encode as JE


editor : List (Html.Attribute msg) -> List (Html msg) -> Html msg
editor attr =
    Attr.style "display" "block"
        :: attr
        |> Html.node "code-editor"


onChange : (String -> msg) -> Html.Attribute msg
onChange msg =
    JD.string
        |> JD.at [ "target", "value" ]
        |> JD.map msg
        |> Html.Events.on "editorChanged"


value : String -> Html.Attribute msg
value =
    JE.string >> Attr.property "value"


mode : String -> Html.Attribute msg
mode =
    JE.string >> Attr.property "mode"


theme : String -> Html.Attribute msg
theme =
    JE.string >> Attr.property "theme"


tabSize : Int -> Html.Attribute msg
tabSize =
    JE.int >> Attr.property "tabSize"


useSoftTabs : Bool -> Html.Attribute msg
useSoftTabs =
    boolean "useSoftTabs"


readOnly : Bool -> Html.Attribute msg
readOnly =
    boolean "readOnly"


showCursor : Bool -> Html.Attribute msg
showCursor =
    boolean "showCursor"


highlightActiveLine : Bool -> Html.Attribute msg
highlightActiveLine =
    boolean "highlightActiveLine"


showGutter : Bool -> Html.Attribute msg
showGutter =
    boolean "showGutter"


showPrintMargin : Bool -> Html.Attribute msg
showPrintMargin =
    boolean "showPrintMargin"


maxLines : Int -> Html.Attribute msg
maxLines =
    JE.int >> Attr.property "maxLines"


annotations : JE.Value -> Html.Attribute msg
annotations =
    Attr.property "annotations"


useWrapMode : Bool -> Html.Attribute msg
useWrapMode =
    boolean "useWrapMode"


enableBasicAutocompletion : Bool -> Html.Attribute msg
enableBasicAutocompletion =
    boolean "enableBasicAutocompletion"


enableLiveAutocompletion : Bool -> Html.Attribute msg
enableLiveAutocompletion =
    boolean "enableLiveAutocompletion"


enableSnippets : Bool -> Html.Attribute msg
enableSnippets =
    boolean "enableSnippets"


extensions : List String -> Html.Attribute msg
extensions =
    JE.list JE.string >> Attr.property "extensions"


boolean : String -> Bool -> Html.Attribute msg
boolean prop =
    JE.bool >> Attr.property prop
