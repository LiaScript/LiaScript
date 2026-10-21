module Lia.Markdown.Code.Editor exposing
    ( Cursor
    , aceOptions
    , annotations
    , catchCursorUpdates
    , decodeCursor
    , editor
    , emptyCursor
    , enableBasicAutocompletion
    , enableLiveAutocompletion
    , enableSnippets
    , firstLineNumber
    , focusing
    , fontSize
    , highlightActiveLine
    , keyBindings
    , label
    , marker
    , maxLines
    , mode
    , onChange
    , onChangeCursor
    , onChangeCursorValue
    , onChangeEvent
    , onCtrlEnter
    , onKeyBinding
    , readOnly
    , rtl
    , rtlText
    , setCursors
    , showCursor
    , showGutter
    , showPrintMargin
    , tabSize
    , theme
    , useSoftTabs
    , value
    , valueAndCursor
    )

{-| Elm interface of the `lia-editor` web component (Ace editor, see
`src/typescript/webcomponents/editor.ts`). Settings are passed as DOM
properties, the editor reports back via custom events.
-}

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
import Json.Decode as JD
import Json.Encode as JE


{-| Cursor position and selection (`[startRow, startColumn, endRow, endColumn]`).
-}
type alias Cursor =
    { position :
        { row : Int
        , column : Int
        }
    , selection : List Int
    }


emptyCursor : Cursor
emptyCursor =
    { position = { row = 0, column = 0 }
    , selection = []
    }


decodeCursor : JD.Decoder Cursor
decodeCursor =
    JD.map2 Cursor
        (JD.field "position"
            (JD.map2 (\row column -> { row = row, column = column })
                (JD.field "row" JD.int)
                (JD.field "column" JD.int)
            )
        )
        (JD.field "selection" (JD.list JD.int))


{-| The editor element, always displayed as block.
-}
editor : List (Html.Attribute msg) -> List (Html msg) -> Html msg
editor attr =
    Attr.style "display" "block"
        :: attr
        |> Html.node "lia-editor"


{-| The complete new content after every change.
-}
onChange : (String -> msg) -> Html.Attribute msg
onChange msg =
    JD.string
        |> JD.at [ "detail" ]
        |> JD.map msg
        |> Html.Events.on "editorUpdate"


{-| The single changes (Ace deltas, not decoded) for synchronizing with
others, the editor fires them instead of `onChange` when it catches cursor
updates.
-}
onChangeEvent : (JD.Value -> msg) -> Html.Attribute msg
onChangeEvent msg =
    JD.value
        |> JD.at [ "detail" ]
        |> JD.map msg
        |> Html.Events.on "editorUpdateEvent"


{-| This attribute has to be set to true, to instruct the editor to send cursor updates.
Otherwise, `onChangeCursor` and `onChangeCursorValue` remain silent.
-}
catchCursorUpdates : Bool -> Html.Attribute msg
catchCursorUpdates =
    boolean "catchCursorUpdates"


{-| Cursor movements, decoded.
-}
onChangeCursor : (Cursor -> msg) -> Html.Attribute msg
onChangeCursor msg =
    decodeCursor
        |> JD.at [ "detail" ]
        |> JD.map msg
        |> Html.Events.on "editorUpdateCursor"


{-| Cursor movements, not decoded, to be passed on to others.
-}
onChangeCursorValue : (JD.Value -> msg) -> Html.Attribute msg
onChangeCursorValue msg =
    JD.value
        |> JD.at [ "detail" ]
        |> JD.map msg
        |> Html.Events.on "editorUpdateCursor"


{-| Ctrl-Enter (Command-Enter on Mac) was pressed.
-}
onCtrlEnter : msg -> Html.Attribute msg
onCtrlEnter msg =
    JD.succeed msg
        |> Html.Events.on "editorCtrlEnter"


{-| Show the cursors of other users.
-}
setCursors : List { cursor | id : String, color : String, state : Cursor, name : String } -> Html.Attribute msg
setCursors =
    JE.list
        (\cursor ->
            JE.object
                [ ( "id", JE.string cursor.id )
                , ( "color", JE.string cursor.color )
                , ( "position"
                  , JE.object
                        [ ( "row", JE.int cursor.state.position.row )
                        , ( "column", JE.int cursor.state.position.column )
                        ]
                  )
                , ( "selection", JE.list JE.int cursor.state.selection )
                , ( "name", JE.string cursor.name )
                ]
        )
        >> Attr.property "cursors"


value : String -> Html.Attribute msg
value =
    JE.string >> Attr.property "value"


{-| Set the content and move the cursor to `pos`.
-}
valueAndCursor : String -> { row : Int, column : Int } -> Html.Attribute msg
valueAndCursor str pos =
    JE.list identity
        [ JE.string str
        , JE.object
            [ ( "row", JE.int pos.row )
            , ( "column", JE.int pos.column )
            ]
        ]
        |> Attr.property "value"


firstLineNumber : Int -> Html.Attribute msg
firstLineNumber =
    JE.int >> Attr.property "firstLineNumber"


mode : String -> Html.Attribute msg
mode =
    JE.string >> Attr.property "mode"


{-| The name of the editor for screen readers, Ace adds the cursor position.
-}
label : String -> Html.Attribute msg
label =
    Attr.attribute "data-label"


theme : String -> Html.Attribute msg
theme =
    JE.string >> Attr.property "theme"


tabSize : Int -> Html.Attribute msg
tabSize =
    JE.int >> Attr.property "tabSize"


fontSize : String -> Html.Attribute msg
fontSize =
    JE.string >> Attr.property "fontSize"


{-| Highlighted ranges, see `data-marker` in the documentation.
-}
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


{-| The editor grows up to this number of lines, `-1` means no limit.
-}
maxLines : Int -> Html.Attribute msg
maxLines =
    JE.int >> Attr.property "maxLines"


{-| Error/warning annotations of the gutter, as sent by the evaluation.
-}
annotations : JE.Value -> Html.Attribute msg
annotations =
    Attr.property "annotations"


{-| Additional ace options defined by the course author, e.g.
`data-ace-options="spellcheck hardWrap tabSize=8"`, see `editor.ts`.
-}
aceOptions : String -> Html.Attribute msg
aceOptions =
    JE.string >> Attr.property "aceOptions"


enableBasicAutocompletion : Bool -> Html.Attribute msg
enableBasicAutocompletion =
    boolean "enableBasicAutocompletion"


enableLiveAutocompletion : Bool -> Html.Attribute msg
enableLiveAutocompletion =
    boolean "enableLiveAutocompletion"


enableSnippets : Bool -> Html.Attribute msg
enableSnippets =
    boolean "enableSnippets"


{-| Set the text direction to right-to-left. This is needed for languages like Arabic or Hebrew.
-}
rtl : Bool -> Html.Attribute msg
rtl =
    boolean "rtl"


{-| Auto-detect RTL text direction based on the content of the editor. This is needed for languages like Arabic or Hebrew.
-}
rtlText : Bool -> Html.Attribute msg
rtlText =
    boolean "rtlText"


boolean : String -> Bool -> Html.Attribute msg
boolean prop =
    JE.bool >> Attr.property prop


{-| Focus the editor when it is created.
-}
focusing : Html.Attribute msg
focusing =
    boolean "focusing" True


{-| Bind keys to custom events, which can be caught with `onKeyBinding`:

    keyBindings
        [ ( "execute", { win = "Ctrl-Enter", mac = "Command-Enter" }, "editorExecute" )
        , ( "save", { win = "Ctrl-S", mac = "Command-S" }, "editorSave" )
        ]

-}
keyBindings : List ( String, { win : String, mac : String }, String ) -> Html.Attribute msg
keyBindings bindings =
    bindings
        |> List.map
            (\( name, bindKey, eventName ) ->
                ( name
                , JE.object
                    [ ( "bindKey"
                      , JE.object
                            [ ( "win", JE.string bindKey.win )
                            , ( "mac", JE.string bindKey.mac )
                            ]
                      )
                    , ( "eventName", JE.string eventName )
                    ]
                )
            )
        |> JE.object
        |> Attr.property "keyBindings"


{-| Listen for a custom key binding event.
-}
onKeyBinding : String -> msg -> Html.Attribute msg
onKeyBinding eventName msg =
    JD.succeed msg
        |> Html.Events.on eventName
