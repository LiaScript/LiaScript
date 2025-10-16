module Lia.Markdown.Code.Editor exposing
    ( Cursor
    , Event
    , addKeyBinding
    , annotations
    , blockUpdate
    , catchCursorUpdates
    , cursorPosition
    , decodeCursor
    , editor
    , emptyCursor
    , enableBasicAutocompletion
    , enableKeyboardAccessibility
    , enableLiveAutocompletion
    , enableSnippets
    , encode
    , extensions
    , firstLineNumber
    , focusing
    , fontSize
    , highlightActiveLine
    , keyBindings
    , marker
    , maxLines
    , mode
    , onBlur
    , onChange
    , onChangeCursor
    , onChangeCursor2
    , onChangeEvent
    , onChangeEvent2
    , onCtrlEnter
    , onFocus
    , onKeyBinding
    , readOnly
    , removeKeyBinding
    , setCursors
    , showCursor
    , showGutter
    , showPrintMargin
    , tabSize
    , theme
    , useSoftTabs
    , useWrapMode
    , value
    , valueAndCursor
    )

import Array exposing (Array)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
import Json.Decode as JD
import Json.Encode as JE


type alias Event =
    { action : String
    , index : Int
    , content : String
    }


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


encode : Array Event -> JE.Value
encode =
    JE.array encode_


encode_ : Event -> JE.Value
encode_ { action, index, content } =
    JE.object
        [ ( "action", JE.string action )
        , ( "index", JE.int index )
        , ( "content", JE.string content )
        ]


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


editor : List (Html.Attribute msg) -> List (Html msg) -> Html msg
editor attr =
    Attr.style "display" "block"
        :: attr
        |> Html.node "lia-editor"


onChange : (String -> msg) -> Html.Attribute msg
onChange msg =
    JD.string
        |> JD.at [ "detail" ]
        |> JD.map msg
        |> Html.Events.on "editorUpdate"


blockUpdate : Bool -> Html.Attribute msg
blockUpdate =
    boolean "blockUpdate"


onChangeEvent : (Array Event -> msg) -> Html.Attribute msg
onChangeEvent msg =
    JD.map3 Event
        (JD.field "action" JD.string)
        (JD.field "index" JD.int)
        (JD.field "content" JD.string)
        |> JD.array
        |> JD.at [ "detail" ]
        |> JD.map msg
        |> Html.Events.on "editorUpdateEvent"


onChangeEvent2 : (JD.Value -> msg) -> Html.Attribute msg
onChangeEvent2 msg =
    JD.value
        |> JD.at [ "detail" ]
        |> JD.map msg
        |> Html.Events.on "editorUpdateEvent"


{-| This attribute has to be set to true, to instruct the editor to send cursor updates.
Otherwise, the `onChangeCursor` and 'onChangeCursor2' will remain silent.
-}
catchCursorUpdates : Bool -> Html.Attribute msg
catchCursorUpdates =
    boolean "catchCursorUpdates"


onChangeCursor : (Cursor -> msg) -> Html.Attribute msg
onChangeCursor msg =
    decodeCursor
        |> JD.at [ "detail" ]
        |> JD.map msg
        |> Html.Events.on "editorUpdateCursor"


{-| Catch the updated of cursor movements, which for simplicity are not decoded.

    `Cursor --> {row: Int, column: Int}

-}
onChangeCursor2 : (JD.Value -> msg) -> Html.Attribute msg
onChangeCursor2 msg =
    JD.value
        |> JD.at [ "detail" ]
        |> JD.map msg
        |> Html.Events.on "editorUpdateCursor"


{-| Catch the updated of cursor movements, which for simplicity are not decoded.

    `Cursor --> {row: Int, column: Int}

-}
onCtrlEnter : msg -> Html.Attribute msg
onCtrlEnter msg =
    JD.succeed msg
        |> Html.Events.on "editorCtrlEnter"


setCursors : List { cursor | id : String, color : String, state : Cursor } -> Html.Attribute msg
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
                ]
        )
        >> Attr.property "cursors"


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


enableKeyboardAccessibility : Bool -> Html.Attribute msg
enableKeyboardAccessibility =
    boolean "enableKeyboardAccessibility"


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


{-| Set multiple key bindings at once
Example:
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


{-| Add a single key binding
-}
addKeyBinding : String -> { win : String, mac : String } -> String -> Html.Attribute msg
addKeyBinding name bindKey eventName =
    JE.object
        [ ( "name", JE.string name )
        , ( "bindKey"
          , JE.object
                [ ( "win", JE.string bindKey.win )
                , ( "mac", JE.string bindKey.mac )
                ]
          )
        , ( "eventName", JE.string eventName )
        ]
        |> Attr.property "addKeyBindingProp"


{-| Remove a key binding by name
-}
removeKeyBinding : String -> Html.Attribute msg
removeKeyBinding name =
    JE.string name
        |> Attr.property "removeKeyBindingProp"


{-| Listen for custom key binding events
-}
onKeyBinding : String -> msg -> Html.Attribute msg
onKeyBinding eventName msg =
    JD.succeed msg
        |> Html.Events.on eventName


cursorPosition : { row : Int, column : Int } -> Html.Attribute msg
cursorPosition { row, column } =
    JE.object
        [ ( "row", JE.int row )
        , ( "column", JE.int column )
        ]
        |> Attr.property "cursorPos"
