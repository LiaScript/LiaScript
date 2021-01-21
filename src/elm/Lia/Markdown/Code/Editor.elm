module Lia.Markdown.Code.Editor exposing
    ( annotations
    , editor
    , enableBasicAutocompletion
    , enableLiveAutocompletion
    , enableSnippets
    , extensions
    , firstLineNumber
    , focusing
    , fontSize
    , highlightActiveLine
    , marker
    , maxLines
    , mode
    , onBlur
    , onChange
    , onFocus
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
        |> Html.node "lia-editor"


onChange : (String -> msg) -> Html.Attribute msg
onChange msg =
    JD.string
        |> JD.at [ "target", "value" ]
        |> JD.map msg
        |> Html.Events.on "editorChanged"


onFocus : msg -> Html.Attribute msg
onFocus msg =
    JD.bool
        |> JD.at [ "target", "focusing" ]
        |> JD.andThen
            (\b ->
                if b then
                    JD.succeed msg

                else
                    JD.fail "no focus"
            )
        |> Html.Events.on "editorFocus"


onBlur : msg -> Html.Attribute msg
onBlur msg =
    JD.bool
        |> JD.at [ "target", "focusing" ]
        |> JD.andThen
            (\b ->
                if b then
                    JD.fail "no blur"

                else
                    JD.succeed msg
            )
        |> Html.Events.on "editorFocus"


value : String -> Html.Attribute msg
value =
    JE.string >> Attr.property "value"


firstLineNumber : Int -> Html.Attribute msg
firstLineNumber =
    JE.int >> Attr.property "firstLineNumber"


mode : String -> Html.Attribute msg
mode =
    JE.string >> Attr.property "mode"


theme : String -> Html.Attribute msg
theme =
    JE.string >> Attr.property "theme"


tabSize : Int -> Html.Attribute msg
tabSize =
    JE.int >> Attr.property "tabSize"


fontSize : String -> Html.Attribute msg
fontSize =
    JE.string >> Attr.property "fontSize"


marker : String -> Html.Attribute msg
marker =
    JE.string >> Attr.property "marker"


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


focusing : Html.Attribute msg
focusing =
    boolean "focusing" True
