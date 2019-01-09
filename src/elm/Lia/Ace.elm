module Lia.Ace exposing (..)

{-| A library to use Ace editor with Elm.


# Editor

@docs toHtml


# Ace's Attributes

@docs theme, readOnly, mode, value, highlightActiveLine
@docs showPrintMargin, showCursor, showGutter, tabSize, useSoftTabs, useWrapMode
@docs enableBasicAutocompletion, enableLiveAutocompletion, enableSnippets, extensions


# Ace's Events

@docs onSourceChange

-}

import Array exposing (Array)
import Html exposing (Attribute, Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as JD
import Json.Encode as JE
import Native.Ace


{-| Attribute to set the theme to Ace.
Ace.toHtml [ Ace.theme "monokai" ]
-}
theme : String -> Attribute msg
theme val =
    Attributes.property "AceTheme" (JE.string val)


{-| Attribute to set editor in readonly.
Ace.toHtml [ Ace.readOnly true ]
-}
readOnly : Bool -> Attribute msg
readOnly val =
    Attributes.property "AceReadOnly" (JE.bool val)


{-| Attribute to set the mode to Ace.
Ace.toHtml [ Ace.mode "lua" ]
-}
mode : String -> Attribute msg
mode val =
    Attributes.property "AceMode" (JE.string val)


{-| Attribute to set initial value or to update current value of Ace.
Ace.toHtml [ Ace.value "-- It's a source!\nlocal x = 1" ] []
-}
value : String -> Attribute msg
value val =
    Attributes.property "AceValue" (JE.string val)


{-| Attribute to set whether to show the print margin or not.
Ace.toHtml [ Ace.showPrintMargin false ]
-}
showPrintMargin : Bool -> Attribute msg
showPrintMargin val =
    Attributes.property "AceShowPrintMargin" (JE.bool val)


{-| Attribute to set whether show cursor or not
Ace.toHtml [ Ace.showCursor false ]
-}
showCursor : Bool -> Attribute msg
showCursor val =
    Attributes.property "AceShowCursor" (JE.bool val)


{-| Attribute to set whether to show gutter or not.
Ace.toHtml [ Ace.showGutter false ]
-}
showGutter : Bool -> Attribute msg
showGutter val =
    Attributes.property "AceShowGutter" (JE.bool val)


{-| Attribute to set whether to highlight the active line or not.
Ace.toHtml [ Ace.highlightActiveLine false ]
-}
highlightActiveLine : Bool -> Attribute msg
highlightActiveLine val =
    Attributes.property "AceHighlightActiveLine" (JE.bool val)


{-| Attribute to set the tab size.
Ace.toHtml [ Ace.tabSize 4 ]
-}
tabSize : Int -> Attribute msg
tabSize val =
    Attributes.property "AceTabSize" (JE.int val)


maxLines : Int -> Attribute msg
maxLines val =
    Attributes.property "AceMaxLines" (JE.int val)


annotations : JE.Value -> Attribute msg
annotations val =
    Attributes.property "AceAnnotations" val


{-| Attribute to set whether to use soft tabs or not.
Ace.toHtml [ Ace.useSoftTabs false ]
-}
useSoftTabs : Bool -> Attribute msg
useSoftTabs val =
    Attributes.property "AceUseSoftTabs" (JE.bool val)


{-| Attribute to set whether to use wrap mode.
Ace.toHtml [ Ace.useWrapMode false ]
-}
useWrapMode : Bool -> Attribute msg
useWrapMode val =
    Attributes.property "AceUseWrapMode" (JE.bool val)


{-| Attribute to set autocompletion option.
Ace.toHtml [ Ace.enableBasicAutocompletion true ]
-}
enableBasicAutocompletion : Bool -> Attribute msg
enableBasicAutocompletion val =
    Attributes.property "AceEnableBasicAutocompletion" (JE.bool val)


{-| Attribute to set live autocompletion option.
Ace.toHtml [ Ace.enableLiveAutocompletion true ]
-}
enableLiveAutocompletion : Bool -> Attribute msg
enableLiveAutocompletion val =
    Attributes.property "AceEnableLiveAutocompletion" (JE.bool val)


{-| Attribute to activate snippets.
Ace.toHtml [ Ace.enableSnippets true ]
-}
enableSnippets : Bool -> Attribute msg
enableSnippets val =
    Attributes.property "AceEnableSnippets" (JE.bool val)


{-| Set list of extensions for ace.
Ace.toHtml [ Ace.extensions [ "language_tools" ] ]
-}
extensions : List String -> Attribute msg
extensions exts =
    Attributes.property "AceExtensions" (List.map JE.string exts |> JE.list)


{-| Values changes listener. It used to get notifications about changes made by user.
Ace.toHtml [ Ace.onSourceChange model.data ]
-}
onSourceChange : (String -> msg) -> Attribute msg
onSourceChange tagger =
    Events.on "AceSourceChange" (JD.map tagger Events.targetValue)


{-| Creates `Html` instance with Ace attached to it.
Ace.toHtml []
-}
toHtml : List (Attribute msg) -> List (Html msg) -> Html msg
toHtml =
    Native.Ace.toHtml
