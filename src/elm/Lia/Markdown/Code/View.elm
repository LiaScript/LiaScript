module Lia.Markdown.Code.View exposing (view)

{-| A code block: its files (each an editor, named files within an
accordion), for executable projects the controls (run/stop, classroom
toggle, version navigation) and the terminal with the output.
-}

import Accessibility.Aria as A11y_Aria
import Accessibility.Live as A11y_Live
import Accessibility.Role as A11y_Role
import Array exposing (Array)
import Conditional.List as CList
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Html.Keyed as Keyed
import I18n.Translations as Translations
    exposing
        ( Lang
        , baseStop
        , codeBlock
        , codeEditor
        , codeExecute
        , codeFirst
        , codeLast
        , codeMaximize
        , codeMinimize
        , codeNext
        , codePrev
        , codeRunning
        , infoVersion
        )
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Code.Editor as Editor
import Lia.Markdown.Code.Log as Log exposing (Log)
import Lia.Markdown.Code.Sync exposing (Sync)
import Lia.Markdown.Code.Terminal as Terminal
import Lia.Markdown.Code.Types exposing (Code(..), File, Model)
import Lia.Markdown.Code.Update exposing (Msg(..))
import Lia.Markdown.HTML.Attributes as Params exposing (Parameters)
import Lia.Sync.Types as Sync
import Lia.Utils exposing (btnIcon, noTranslate)


{-| `sync` is the classroom code of the section (empty without a classroom),
`cursors` the cursors of the other users in this section.
-}
view :
    { lang : Lang
    , theme : String
    , model : Model
    , code : Code
    , sync : Array Sync
    , cursors : List Sync.Cursor
    }
    -> Html Msg
view { lang, theme, model, code, sync, cursors } =
    case code of
        Highlight id ->
            Array.get id model.highlight
                |> Maybe.map
                    (\project ->
                        viewFiles
                            { code = code
                            , lang = lang
                            , theme = theme
                            , isRunning = True
                            , errors = always JE.null
                            , sync = Nothing
                            , cursors = []
                            }
                            project
                            |> CList.attachIf (not <| Log.isEmpty project.log)
                                (Html.div
                                    [ Attr.class "lia-code-terminal"
                                    , A11y_Aria.label (Translations.codeTerminal lang)
                                    ]
                                    [ viewLog code project.logSize project.log ]
                                )
                    )
                |> Maybe.withDefault [ Html.text "" ]
                |> Html.div [ Attr.class "lia-code lia-code--block" ]

        Evaluate id ->
            case Array.get id model.evaluate of
                Just project ->
                    let
                        shared =
                            project.syncMode && not (Array.isEmpty sync)
                    in
                    Html.div [ Attr.class "lia-code lia-code--block" ]
                        (viewFiles
                            { code = code
                            , lang = lang
                            , theme = theme
                            , isRunning = project.running
                            , errors =
                                annotations <|
                                    if shared then
                                        project.syncLog

                                    else
                                        project.log
                            , sync =
                                if shared then
                                    Array.get id sync

                                else
                                    Nothing
                            , cursors = cursors
                            }
                            project
                            ++ [ viewControl
                                    { lang = lang
                                    , id = id
                                    , version_active = project.version_active
                                    , version_count = Array.length project.version
                                    , running = project.running
                                    , terminal = project.terminal /= Nothing
                                    , sync =
                                        if Array.isEmpty sync then
                                            Nothing

                                        else
                                            Just project.syncMode
                                    }
                               , Html.div
                                    [ Attr.class "lia-code-terminal"
                                    , Attr.id ("lia-code-terminal-" ++ String.fromInt id)
                                    , A11y_Role.log
                                    , A11y_Aria.label (Translations.codeTerminal lang)
                                    , if project.running then
                                        A11y_Live.livePolite

                                      else
                                        Attr.class ""
                                    ]
                                    [ viewLog code
                                        project.logSize
                                        (if shared then
                                            project.syncLog

                                         else
                                            project.log
                                        )
                                    , case project.terminal of
                                        Nothing ->
                                            Html.text ""

                                        Just term ->
                                            term
                                                |> Terminal.view lang
                                                |> Html.map (UpdateTerminal id)
                                    ]
                               ]
                        )

                Nothing ->
                    Html.text ""


{-| The editor annotations of a file, as sent with the last evaluation.
-}
annotations : Log -> Int -> JE.Value
annotations log fileID =
    log.details
        |> List.drop fileID
        |> List.head
        |> Maybe.withDefault JE.null


type alias Config =
    { code : Code
    , lang : Lang
    , theme : String
    , isRunning : Bool
    , errors : Int -> JE.Value
    , sync : Maybe Sync
    , cursors : List Sync.Cursor
    }


viewFiles : Config -> { project | file : Array File, attr : List Parameters } -> List (Html Msg)
viewFiles config project =
    project.file
        |> Array.toList
        |> List.indexedMap (viewFile config)
        |> List.map2 (|>) project.attr


{-| An unnamed file is a plain editor, a named one an accordion item that can
be collapsed and, if executable, expanded to show all lines.
-}
viewFile : Config -> Int -> File -> Parameters -> Html Msg
viewFile config fileID file attr =
    let
        isExecutable =
            isEvaluate config.code

        editor =
            viewEditor
                { lang = config.lang
                , isExecutable = isExecutable
                , theme = config.theme
                , attr = attr
                , isRunning = config.isRunning
                , code = config.code
                , fileID = fileID
                , file = file
                , errors = config.errors fileID
                , sync = Maybe.andThen (Array.get fileID) config.sync
                , cursors = List.filter (\cursor -> cursor.project == idOf config.code && cursor.file == fileID) config.cursors
                }

        copy inverted =
            copyToClipboard config.lang inverted (Params.isSet "data-rtl" attr) config.code fileID

        toggleTitle visible =
            if visible then
                codeMinimize config.lang

            else
                codeMaximize config.lang

        contentID =
            "lia-code-" ++ String.fromInt (idOf config.code) ++ "-" ++ String.fromInt fileID

        minMax =
            if file.visible && isExecutable then
                btnIcon
                    { title = toggleTitle file.fullscreen
                    , msg = Just <| FlipFullscreen config.code fileID
                    , icon =
                        if file.fullscreen then
                            "icon-chevron-up"

                        else
                            "icon-chevron-down"
                    , tabbable = True
                    }
                    [ Attr.class "lia-code__min-max lia-btn--transparent" ]

            else
                Html.text ""
    in
    if file.name == "" then
        Html.div (noTranslate [ Attr.class "lia-code__input" ])
            (editor ++ [ copy False ])

    else
        Html.div (noTranslate [ Attr.class "lia-accordion" ])
            [ Html.div (Attr.class "lia-accordion__item" :: Params.toAttribute attr)
                [ Html.div
                    [ Attr.class "lia-accordion__header" ]
                    [ btnIcon
                        { title = toggleTitle file.visible
                        , msg = Just <| FlipView config.code fileID
                        , icon =
                            if file.visible then
                                "icon-plus"

                            else
                                "icon-minus"
                        , tabbable = True
                        }
                        [ Attr.class "lia-accordion__toggle"
                        , A11y_Aria.expanded file.visible
                        , A11y_Aria.controls [ contentID ]
                        , A11y_Aria.label (toggleTitle file.visible ++ ": " ++ file.name)
                        ]
                    , Html.h3 [ Attr.class "lia-accordion__headline h4" ] [ Html.text file.name ]
                    , copy True
                    ]
                , Html.div
                    [ Attr.classList
                        [ ( "lia-accordion__content", True )
                        , ( "active", file.visible )
                        ]
                    , Attr.id contentID
                    ]
                    [ Html.div
                        [ Attr.class "lia-code__input"
                        , if file.visible then
                            Attr.class ""

                          else
                            Attr.attribute "inert" "true"
                        ]
                        (minMax :: editor)
                    ]
                ]
            ]


isEvaluate : Code -> Bool
isEvaluate code =
    case code of
        Evaluate _ ->
            True

        Highlight _ ->
            False


idOf : Code -> Int
idOf code =
    case code of
        Evaluate id ->
            id

        Highlight id ->
            id


copyToClipboard : Lang -> Bool -> Bool -> Code -> Int -> Html Msg
copyToClipboard lang inverted rtl code fileID =
    btnIcon
        { title = Translations.codeCopy lang
        , msg = Just <| CopyToClipboard code fileID
        , icon = "icon-copy"
        , tabbable = True
        }
        (CList.appendIf rtl
            [ Attr.style "left" "4.4rem"
            , Attr.style "right" "unset"
            ]
            [ Attr.classList
                [ ( "lia-btn--transparent", True )
                , ( "lia-code__copy--inverted", inverted )
                , ( "lia-code__copy", not inverted )
                ]
            ]
        )


{-| The editor of a file, `sync` is the shared classroom code that replaces
the local one. Executable files are read-only while running or if marked
with `data-readonly`, highlighted ones unless `data-readonly="false"`.
At most 16 lines are shown unless the file is in fullscreen.
-}
viewEditor :
    { lang : Lang
    , isExecutable : Bool
    , theme : String
    , attr : Parameters
    , isRunning : Bool
    , code : Code
    , fileID : Int
    , file : File
    , errors : JE.Value
    , sync : Maybe String
    , cursors : List Sync.Cursor
    }
    -> List (Html Msg)
viewEditor { lang, isExecutable, theme, attr, isRunning, code, fileID, file, errors, sync, cursors } =
    let
        id =
            idOf code

        content =
            Maybe.withDefault file.code sync

        totalLines =
            List.length (String.lines content)

        maxLines =
            if file.fullscreen then
                totalLines

            else
                min 16 totalLines

        readOnly =
            if isExecutable then
                isRunning || Params.isSet "data-readonly" attr

            else
                Params.get "data-readonly" attr == Nothing || Params.isSet "data-readonly" attr

        int name default =
            Params.get name attr
                |> Maybe.andThen String.toInt
                |> Maybe.withDefault default

        string name default =
            Params.get name attr
                |> Maybe.withDefault default
    in
    [ Editor.editor
        ([ Editor.value content
         , Editor.label
            ((if readOnly then
                codeBlock lang

              else
                codeEditor lang
             )
                ++ ", "
                ++ file.lang
                ++ (if String.isEmpty file.name then
                        ""

                    else
                        ": " ++ file.name
                   )
            )
         , Editor.setCursors cursors
         , Editor.mode file.lang
         , Editor.theme (string "data-theme" theme)
         , Editor.maxLines
            (if maxLines > 16 then
                -1

             else
                maxLines
            )
         , Editor.readOnly readOnly
         , Editor.highlightActiveLine (not readOnly)
         , Editor.tabSize (int "data-tabsize" 2)
         , Editor.fontSize (string "data-fontsize" "1.5rem")
         , Editor.marker (string "data-marker" "")
         , Editor.firstLineNumber (int "data-firstlinenumber" 1)
         , Editor.rtl (Params.isSet "data-rtl" attr)
         , Editor.rtlText (Params.isSet "data-rtltext" attr)
         , Editor.showGutter <|
            if Params.get "data-showgutter" attr /= Nothing then
                Params.isSet "data-showgutter" attr

            else
                isExecutable
         , Editor.useSoftTabs False
         , Editor.annotations errors
         , Editor.enableBasicAutocompletion isExecutable
         , Editor.enableLiveAutocompletion isExecutable
         , Editor.enableSnippets isExecutable
         , Editor.aceOptions (string "data-ace-options" "")
         ]
            ++ minHeight file.visible maxLines
            ++ Params.toAttribute attr
            |> CList.appendIf (not readOnly)
                (if sync == Nothing then
                    [ Editor.catchCursorUpdates False
                    , Editor.onChange <| Update code fileID
                    ]

                 else
                    [ Editor.catchCursorUpdates True
                    , Editor.onChangeEvent <| Synchronize id fileID
                    , Editor.onChangeCursorValue <| SynchronizeCursor id fileID
                    ]
                )
            |> CList.appendIf isExecutable [ Editor.onCtrlEnter (Eval id) ]
        )
        []
    , if readOnly then
        -- Ace hides its content from screen readers, which would skip the
        -- code in browse mode, thus it is repeated invisibly
        Html.pre [ Attr.class "hidden-visually" ] [ Html.code [] [ Html.text content ] ]

      else
        Html.text ""
    ]


{-| Reserve the height of `lines` lines, so the page does not jump while the
editor gets initialized.
-}
minHeight : Bool -> Int -> List (Html.Attribute msg)
minHeight visible lines =
    [ Attr.style "min-height" <|
        if visible then
            "calc( " ++ String.fromInt lines ++ " * var(--global-font-size, 1.5rem) * var(--font-size-multiplier) * 1.3333 + 1.47rem)"

        else
            "0px"
    , Attr.style "transition" "min-height 0.25s ease-out"
    ]


{-| The output, scrolled to the end and resizable by the user.
-}
viewLog : Code -> Maybe String -> Log -> Html Msg
viewLog code height log =
    if Array.isEmpty log.messages then
        Html.text ""

    else
        Log.view log
            |> Keyed.node "lia-terminal"
                -- the surrounding lia-code-terminal is the log, the output
                -- scrolls and can therefore be focused
                [ Attr.class "lia-code-terminal__output"
                , Attr.tabindex 0
                , onChangeHeight (Resize code)
                , height
                    |> Maybe.map (JE.string >> Attr.property "height")
                    |> Maybe.withDefault (Attr.class "")
                , (Log.length log.messages * 28 + 14)
                    |> String.fromInt
                    |> JE.string
                    |> Attr.property "scrollTop"
                ]


{-| Run or stop, switch between the local and the collaborative editor (in
a classroom) and navigate through the versions. Version navigation is
disabled while running and in the collaborative editor.
-}
viewControl :
    { lang : Lang
    , id : Int
    , version_active : Int
    , version_count : Int
    , running : Bool
    , terminal : Bool
    , sync : Maybe Bool
    }
    -> Html Msg
viewControl { lang, id, version_active, version_count, running, terminal, sync } =
    let
        shared =
            sync == Just True

        version title icon disabled msg =
            btnIcon
                { title = title lang
                , tabbable = True
                , msg =
                    if disabled || shared then
                        Nothing

                    else
                        Just msg
                , icon = icon
                }
                [ Attr.class "lia-btn--transparent" ]

        isFirst =
            running || version_active == 0

        isLast =
            running || version_active == version_count - 1
    in
    Html.div [ Attr.class "lia-code-control" ]
        [ Html.div [ Attr.class "lia-code-control__action" ]
            [ case ( running, terminal ) of
                ( True, False ) ->
                    btnIcon
                        { title = codeRunning lang
                        , msg = Nothing
                        , tabbable = True
                        , icon = "icon-refresh rotating"
                        }
                        [ Attr.class "is-disabled lia-btn--transparent" ]

                ( True, True ) ->
                    btnIcon
                        { title = baseStop lang
                        , msg = Just <| Stop id
                        , tabbable = True
                        , icon = "icon-stop-circle"
                        }
                        [ Attr.class "lia-btn--transparent" ]

                _ ->
                    btnIcon
                        { title = codeExecute lang
                        , msg = Just <| Eval id
                        , tabbable = True
                        , icon = "icon-compile-circle"
                        }
                        [ Attr.class "lia-btn--transparent"
                        , A11y_Aria.keyShortcuts [ "Control+Enter", "Meta+Enter" ]
                        ]
            , case sync of
                Nothing ->
                    Html.text ""

                Just syncMode ->
                    btnIcon
                        { title =
                            if syncMode then
                                "switch to base editor"

                            else
                                "switch to collaborative editor"
                        , tabbable = True
                        , msg =
                            if running then
                                Nothing

                            else
                                Just (ToggleSync id)
                        , icon =
                            if syncMode then
                                "icon-class-on"

                            else
                                "icon-class-off"
                        }
                        [ Attr.class "lia-btn--transparent" ]
            ]
        , Html.div
            [ Attr.class "lia-code-control__version"
            , if shared then
                Attr.style "filter" "blur(1.2px)"

              else
                Attr.class ""
            ]
            [ version codeFirst "icon-end-left" isFirst (First id)
            , version codePrev "icon-chevron-left" isFirst (Load id (version_active - 1))
            , Html.span
                [ Attr.class "lia-label" ]
                [ Html.span [ Attr.class "hidden-visually" ] [ Html.text (String.trimRight (infoVersion lang) ++ " ") ]
                , Html.text (String.fromInt version_active)
                ]
            , version codeNext "icon-chevron-right" isLast (Load id (version_active + 1))
            , version codeLast "icon-end-right" isLast (Last id)
            ]
        ]


onChangeHeight : (String -> msg) -> Html.Attribute msg
onChangeHeight msg =
    JD.string
        |> JD.at [ "target", "height" ]
        |> JD.map msg
        |> Event.on "onchangeheight"
