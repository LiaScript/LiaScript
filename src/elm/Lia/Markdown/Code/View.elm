module Lia.Markdown.Code.View exposing (view)

import Accessibility.Live as A11y_Live
import Accessibility.Role as A11y_Role
import Accessibility.Widget as A11y_Widget
import Array exposing (Array)
import Conditional.List as CList
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Html.Keyed as Keyed
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Code.Editor as Editor
import Lia.Markdown.Code.Log as Log exposing (Log)
import Lia.Markdown.Code.Sync exposing (Sync, sync)
import Lia.Markdown.Code.Terminal as Terminal
import Lia.Markdown.Code.Types exposing (Code(..), File, Model)
import Lia.Markdown.Code.Update exposing (Msg(..))
import Lia.Markdown.HTML.Attributes as Params exposing (Parameters)
import Lia.Utils exposing (btnIcon, noTranslate)
import Translations
    exposing
        ( Lang
        , codeExecute
        , codeFirst
        , codeLast
        , codeMaximize
        , codeMinimize
        , codeNext
        , codePrev
        , codeRunning
        )


view : { lang : Lang, theme : String, model : Model, code : Code, sync : Array Sync } -> Html Msg
view { lang, theme, model, code, sync } =
    case code of
        Highlight id_1 ->
            Array.get id_1 model.highlight
                |> Maybe.map
                    (\pro ->
                        pro.file
                            |> Array.toList
                            |> List.indexedMap
                                (viewCode
                                    { isExecutable = False
                                    , lang = lang
                                    , theme = theme
                                    , isRunning = True
                                    , errors = always JE.null
                                    , sync = Nothing
                                    , id_1 = id_1
                                    }
                                )
                            |> List.map2 (\a e -> e a) pro.attr
                            |> CList.attachIf (not <| Log.isEmpty pro.log)
                                (Html.div
                                    [ Attr.class "lia-code-terminal"
                                    , A11y_Role.log
                                    , A11y_Widget.label (Translations.codeTerminal lang)
                                    ]
                                    [ view_result (Highlight id_1)
                                        pro.logSize
                                        (if pro.syncMode then
                                            sync
                                                |> Array.get id_1
                                                |> Maybe.map .log
                                                |> Maybe.withDefault Log.empty

                                         else
                                            pro.log
                                        )
                                    ]
                                )
                    )
                |> Maybe.withDefault [ Html.text "" ]
                |> Html.div [ Attr.class "lia-code lia-code--block" ]

        Evaluate id_1 ->
            case Array.get id_1 model.evaluate of
                Just project ->
                    let
                        errors =
                            get_annotations <|
                                if project.syncMode == True && not (Array.isEmpty sync) then
                                    sync
                                        |> Array.get id_1
                                        |> Maybe.map .log
                                        |> Maybe.withDefault Log.empty

                                else
                                    project.log
                    in
                    Html.div [ Attr.class "lia-code lia-code--block" ]
                        (List.append
                            (project.file
                                |> Array.toList
                                |> List.indexedMap
                                    (viewCode
                                        { isExecutable = True
                                        , lang = lang
                                        , theme = theme
                                        , isRunning = project.running
                                        , errors = errors
                                        , sync =
                                            if project.syncMode == True && not (Array.isEmpty sync) then
                                                Array.get id_1 sync

                                            else
                                                Nothing
                                        , id_1 = id_1
                                        }
                                    )
                                |> List.map2 (\a e -> e a) project.attr
                            )
                            [ view_control
                                { lang = lang
                                , id = id_1
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
                                , A11y_Role.log
                                , A11y_Widget.label (Translations.codeTerminal lang)
                                , if project.running then
                                    A11y_Live.livePolite

                                  else
                                    Attr.class ""
                                ]
                                [ view_result (Evaluate id_1)
                                    project.logSize
                                    (if project.syncMode then
                                        sync
                                            |> Array.get id_1
                                            |> Maybe.map .log
                                            |> Maybe.withDefault Log.empty

                                     else
                                        project.log
                                    )
                                , case project.terminal of
                                    Nothing ->
                                        Html.text ""

                                    Just term ->
                                        term
                                            |> Terminal.view
                                            |> Html.map (UpdateTerminal id_1)
                                ]
                            ]
                        )

                Nothing ->
                    Html.text ""


get_annotations : Log -> Int -> JE.Value
get_annotations log file_id =
    log.details
        |> list_get file_id
        |> Maybe.withDefault JE.null


list_get : Int -> List a -> Maybe a
list_get idx list =
    case list of
        [] ->
            Nothing

        x :: xs ->
            if idx == 0 then
                Just x

            else
                list_get (idx - 1) xs


viewCode :
    { isExecutable : Bool
    , lang : Lang
    , theme : String
    , isRunning : Bool
    , errors : Int -> JE.Value
    , sync : Maybe Sync
    , id_1 : Int
    }
    -> Int
    -> File
    -> Parameters
    -> Html Msg
viewCode { isExecutable, lang, theme, isRunning, errors, sync, id_1 } id_2 file attr =
    if file.name == "" then
        Html.div (noTranslate [ Attr.class "lia-code__input" ])
            [ evaluate
                { isExecutable = isExecutable
                , theme = theme
                , attr = attr
                , isRunning = isRunning
                , id_1 = id_1
                , id_2 = id_2
                , file = file
                , errors = errors id_2
                , sync = Maybe.andThen (.file >> Array.get id_2) sync
                }
            ]

    else
        Html.div (noTranslate [ Attr.class "lia-accordion" ])
            [ Html.div (Attr.class "lia-accordion__item" :: Params.toAttribute attr)
                [ Html.label
                    [ Attr.class "lia-accordion__header"
                    , A11y_Widget.label <|
                        file.name
                            ++ " "
                            ++ (if file.visible then
                                    codeMinimize lang

                                else
                                    codeMaximize lang
                               )
                    ]
                    [ btnIcon
                        { title =
                            if file.visible then
                                codeMinimize lang

                            else
                                codeMaximize lang
                        , msg =
                            Just <|
                                FlipView
                                    (if isExecutable then
                                        Evaluate id_1

                                     else
                                        Highlight id_1
                                    )
                                    id_2
                        , icon =
                            if file.visible then
                                "icon-plus"

                            else
                                "icon-minus"
                        , tabbable = True
                        }
                        [ Attr.class "lia-accordion__toggle" ]
                    , Html.h3 [ Attr.class "lia-accordion__headline h4" ] [ Html.text file.name ]
                    ]
                , Html.div
                    [ Attr.classList
                        [ ( "lia-accordion__content", True )
                        , ( "active", file.visible )
                        ]
                    ]
                    [ Html.div [ Attr.class "lia-code__input" ]
                        [ if file.visible && isExecutable then
                            btnIcon
                                { title =
                                    if file.fullscreen then
                                        codeMinimize lang

                                    else
                                        codeMaximize lang
                                , msg =
                                    Just <| FlipFullscreen (Evaluate id_1) id_2
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
                        , evaluate
                            { isExecutable = isExecutable
                            , theme = theme
                            , attr = attr
                            , isRunning = isRunning
                            , id_1 = id_1
                            , id_2 = id_2
                            , file = file
                            , errors = errors id_2
                            , sync = Maybe.andThen (.file >> Array.get id_2) sync
                            }
                        ]
                    ]
                ]
            ]


toStyle : Bool -> Int -> List (Html.Attribute msg)
toStyle visible pix =
    [ Attr.style "min-height" <|
        if visible then
            "calc( " ++ String.fromInt pix ++ " * var(--global-font-size, 1.5rem) * var(--font-size-multiplier) * 1.3333 + 1.47rem)"

        else
            "0px"
    , Attr.style "transition" "min-height 0.25s ease-out"
    ]


lines : String -> Int
lines code =
    code
        |> String.lines
        |> List.length



-- highlight : String -> Parameters -> File -> Html Msg
-- highlight theme attr file =
--     let
--         readOnly =
--             if Params.get "data-readonly" attr == Nothing then
--                 True
--             else
--                 Params.isSet "data-readonly" attr
--     in
--     Editor.editor
--         (attr
--             |> Params.toAttribute
--             |> List.append
--                 [ Editor.value file.code
--                 , Editor.mode file.lang
--                 , attr
--                     |> Params.get "data-theme"
--                     |> Maybe.withDefault theme
--                     |> Editor.theme
--                 , attr
--                     |> Params.get "data-tabsize"
--                     |> Maybe.andThen String.toInt
--                     |> Maybe.withDefault 2
--                     |> Editor.tabSize
--                 , attr
--                     |> Params.get "data-marker"
--                     |> Maybe.withDefault ""
--                     |> Editor.marker
--                 , attr
--                     |> Params.get "data-firstlinenumber"
--                     |> Maybe.andThen String.toInt
--                     |> Maybe.withDefault 1
--                     |> Editor.firstLineNumber
--                 , Editor.useSoftTabs False
--                 , Editor.readOnly readOnly
--                 , Editor.showCursor (not readOnly)
--                 , Editor.highlightActiveLine False
--                 , attr
--                     |> Params.isSet "data-showgutter"
--                     |> Editor.showGutter
--                 , Editor.showPrintMargin False
--                 , attr
--                     |> Params.get "data-fontsize"
--                     |> Maybe.withDefault "1.5rem"
--                     |> Editor.fontSize
--                 ]
--         )
--         []


evaluate :
    { isExecutable : Bool
    , theme : String
    , attr : Parameters
    , isRunning : Bool
    , id_1 : Int
    , id_2 : Int
    , file : File
    , errors : JE.Value
    , sync : Maybe String
    }
    -> Html Msg
evaluate { isExecutable, theme, attr, isRunning, id_1, id_2, file, errors, sync } =
    let
        total_lines =
            lines file.code

        max_lines =
            if file.fullscreen then
                total_lines

            else if total_lines > 16 then
                16

            else
                total_lines

        readOnly =
            if isExecutable then
                if isRunning then
                    isRunning

                else
                    Params.isSet "data-readonly" attr

            else if Params.get "data-readonly" attr == Nothing then
                True

            else
                Params.isSet "data-readonly" attr
    in
    Editor.editor
        (attr
            |> Params.toAttribute
            |> List.append (toStyle file.visible max_lines)
            |> CList.addIf (not readOnly)
                (if sync == Nothing then
                    Editor.onChange <| Update id_1 id_2

                 else
                    Editor.onChangeEvent2 <| Synchronize id_1 id_2
                )
            |> List.append
                [ sync
                    |> Maybe.withDefault file.code
                    |> Editor.value
                , Editor.mode file.lang
                , attr
                    |> Params.get "data-theme"
                    |> Maybe.withDefault theme
                    |> Editor.theme
                , Editor.maxLines
                    (if max_lines > 16 then
                        -1

                     else
                        max_lines
                    )
                , Editor.readOnly readOnly
                , Editor.highlightActiveLine (not readOnly)
                , attr
                    |> Params.get "data-tabsize"
                    |> Maybe.andThen String.toInt
                    |> Maybe.withDefault 2
                    |> Editor.tabSize
                , attr
                    |> Params.get "data-fontsize"
                    |> Maybe.withDefault "1.5rem"
                    |> Editor.fontSize
                , attr
                    |> Params.get "data-marker"
                    |> Maybe.withDefault ""
                    |> Editor.marker
                , attr
                    |> Params.get "data-firstlinenumber"
                    |> Maybe.andThen String.toInt
                    |> Maybe.withDefault 1
                    |> Editor.firstLineNumber
                , Editor.showGutter <|
                    if Params.get "data-showgutter" attr /= Nothing then
                        attr
                            |> Params.isSet "data-showgutter"

                    else
                        isExecutable
                , Editor.useSoftTabs False
                , Editor.annotations errors
                , Editor.enableBasicAutocompletion isExecutable
                , Editor.enableLiveAutocompletion isExecutable
                , Editor.enableSnippets isExecutable
                , Editor.extensions [ "language_tools" ]
                ]
        )
        []


view_result : Code -> Maybe String -> Log -> Html Msg
view_result code height log =
    if Array.isEmpty log.messages then
        Html.text ""

    else
        Log.view log
            |> Keyed.node "lia-terminal"
                [ Attr.class "lia-code-terminal__output"
                , Resize code
                    |> onChangeHeight
                , height
                    |> Maybe.map (JE.string >> Attr.property "height")
                    |> Maybe.withDefault (Attr.class "")
                , log.messages
                    |> Log.length
                    |> (*) 2
                    |> scroll_to_end
                ]


scroll_to_end : Int -> Html.Attribute msg
scroll_to_end lines_ =
    lines_
        |> (*) 14
        |> (+) 14
        |> String.fromInt
        |> JE.string
        |> Attr.property "scrollTop"


view_control :
    { lang : Lang
    , id : Int
    , version_active : Int
    , version_count : Int
    , running : Bool
    , terminal : Bool
    , sync : Maybe Bool
    }
    -> Html Msg
view_control { lang, id, version_active, version_count, running, terminal, sync } =
    let
        forward =
            running || (version_active == 0)

        backward =
            running || (version_active == (version_count - 1))

        deactivate_control =
            sync == Just True
    in
    Html.div [ Attr.class "lia-code-control" ]
        [ Html.div [ Attr.class "lia-code-control__action" ]
            [ case ( running, terminal ) of
                ( True, False ) ->
                    btnIcon
                        { title = codeRunning lang
                        , msg = Nothing
                        , tabbable = False
                        , icon = "icon-refresh rotating"
                        }
                        [ Attr.class "is-disabled lia-btn--transparent" ]

                ( True, True ) ->
                    btnIcon
                        { title = codeRunning lang
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
                        [ Attr.class "lia-btn--transparent" ]
            , case sync of
                Nothing ->
                    Html.text ""

                Just True ->
                    btnIcon
                        { title = "Switch to Editor"
                        , tabbable = not running
                        , msg =
                            if running then
                                Nothing

                            else
                                Just (ToggleSync id)
                        , icon = "icon-sync"
                        }
                        [ Attr.class "lia-btn--transparent" ]

                Just False ->
                    btnIcon
                        { title = "Switch to Sync"
                        , tabbable = not running
                        , msg =
                            if running then
                                Nothing

                            else
                                Just (ToggleSync id)
                        , icon = "icon-person"
                        }
                        [ Attr.class "lia-btn--transparent" ]
            ]
        , Html.div
            [ Attr.class "lia-code-control__version"
            , if deactivate_control then
                Attr.style "filter" "blur(1.2px)"

              else
                Attr.class ""
            ]
            [ btnIcon
                { title = codeFirst lang
                , tabbable = not (forward || deactivate_control)
                , msg =
                    if forward || deactivate_control then
                        Nothing

                    else
                        Just <| First id
                , icon = "icon-end-left"
                }
                [ Attr.class "lia-btn--transparent" ]
            , btnIcon
                { title = codePrev lang
                , tabbable = not (forward || deactivate_control)
                , msg =
                    if forward || deactivate_control then
                        Nothing

                    else
                        Just <| Load id (version_active - 1)
                , icon = "icon-chevron-left"
                }
                [ Attr.class "lia-btn--transparent" ]
            , Html.span
                [ Attr.class "lia-label" ]
                [ Html.text (String.fromInt version_active) ]
            , btnIcon
                { title = codeNext lang
                , tabbable = not (backward || deactivate_control)
                , msg =
                    if backward || deactivate_control then
                        Nothing

                    else
                        Just <| Load id (version_active + 1)
                , icon = "icon-chevron-right"
                }
                [ Attr.class "lia-btn--transparent" ]
            , btnIcon
                { title = codeLast lang
                , tabbable = not (backward || deactivate_control)
                , msg =
                    if backward || deactivate_control then
                        Nothing

                    else
                        Just <| Last id
                , icon = "icon-end-right"
                }
                [ Attr.class "lia-btn--transparent" ]
            ]
        ]


onChangeHeight : (String -> msg) -> Html.Attribute msg
onChangeHeight msg =
    JD.string
        |> JD.at [ "target", "height" ]
        |> JD.map msg
        |> Event.on "onchangeheight"
