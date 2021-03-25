module Lia.Markdown.Code.View exposing (view)

import Array
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Html.Keyed as Keyed
import Json.Encode as JE
import Lia.Markdown.Code.Editor as Editor
import Lia.Markdown.Code.Log as Log exposing (Log)
import Lia.Markdown.Code.Terminal as Terminal
import Lia.Markdown.Code.Types exposing (Code(..), File, Model, Snippet, Vector)
import Lia.Markdown.Code.Update exposing (Msg(..))
import Lia.Markdown.HTML.Attributes as Params exposing (Parameters)
import Lia.Utils exposing (btnIcon)
import Translations exposing (Lang, codeExecute, codeFirst, codeLast, codeMaximize, codeMinimize, codeNext, codePrev, codeRunning)


view : Lang -> String -> Model -> Code -> Html Msg
view lang theme model code =
    case code of
        Highlight lang_title_code ->
            lang_title_code
                |> List.map (view_code lang theme)
                |> Html.div [ Attr.class "lia-code lia-code--block" ]

        Evaluate id_1 ->
            case Array.get id_1 model.evaluate of
                Just project ->
                    let
                        errors =
                            get_annotations project.log
                    in
                    Html.div [ Attr.class "lia-code lia-code--block" ]
                        (List.append
                            (project.file
                                |> Array.toList
                                |> List.indexedMap (view_eval lang theme project.running errors id_1)
                                |> List.map2 (\a e -> e a) project.attr
                            )
                            [ view_control lang
                                id_1
                                project.version_active
                                (Array.length project.version)
                                project.running
                                (project.terminal /= Nothing)
                            , Html.div [ Attr.class "lia-code-terminal" ]
                                [ view_result project.log
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


view_code : Lang -> String -> Snippet -> Html Msg
view_code lang theme snippet =
    Html.div [ Attr.class "lia-accordion" ]
        [ Html.div [ Attr.class "lia-accordion__item" ]
            [ if snippet.name == "" then
                Html.text ""

              else
                Html.div [ Attr.class "lia-accordion__header" ]
                    [ Html.h3
                        [ Attr.class "lia-accordion__headline" ]
                        [ Html.text snippet.name
                        ]
                    , btnIcon
                        { title = codeMaximize lang
                        , icon = "icon-minus"
                        , msg = Just <| FlipView -1 -1
                        , tabbable = False
                        }
                        [ Attr.class "lia-accordion__toggle"
                        ]
                    ]
            , Html.div [ Attr.class "lia-accordion__content" ]
                [ Html.div [ Attr.class "lia-code__input" ] [ highlight theme snippet.attr snippet.lang snippet.code ]
                ]
            ]
        ]


view_eval : Lang -> String -> Bool -> (Int -> JE.Value) -> Int -> Int -> File -> Parameters -> Html Msg
view_eval lang theme running errors id_1 id_2 file attr =
    if file.name == "" then
        Html.div [ Attr.class "lia-code__input" ] [ evaluate theme attr running ( id_1, id_2 ) file (errors id_2) ]

    else
        Html.div [ Attr.class "lia-accordion" ]
            [ Html.div (Attr.class "lia-accordion__item" :: Params.toAttribute attr)
                [ Html.div [ Attr.class "lia-accordion__header" ]
                    [ Html.h3 [ Attr.class "lia-accordion__headline" ] [ Html.text file.name ]
                    , btnIcon
                        { title =
                            if file.visible then
                                codeMaximize lang

                            else
                                codeMaximize lang
                        , msg = Just <| FlipView id_1 id_2
                        , icon =
                            if file.visible then
                                "icon-minus"

                            else
                                "icon-plus"
                        , tabbable = True
                        }
                        [ Attr.class "lia-accordion__toggle" ]
                    ]
                , Html.div
                    [ Attr.classList
                        [ ( "lia-accordion__content", True )
                        , ( "active", file.visible )
                        ]
                    ]
                    [ Html.div [ Attr.class "lia-code__input" ]
                        [ if file.visible then
                            btnIcon
                                { title =
                                    if file.fullscreen then
                                        codeMaximize lang

                                    else
                                        codeMaximize lang
                                , msg = Just <| FlipFullscreen id_1 id_2
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
                        , evaluate theme attr running ( id_1, id_2 ) file (errors id_2)
                        ]
                    ]
                ]
            ]


toStyle : Bool -> Int -> List (Html.Attribute msg)
toStyle visible pix =
    [ Attr.style "max-height"
        (if visible then
            String.fromInt pix ++ "px"

         else
            "0px"
        )
    , Attr.style "transition" "max-height 0.25s ease-out"
    ]


lines : String -> Int
lines code =
    code
        |> String.lines
        |> List.length


pixel : Int -> Int
pixel from_lines =
    from_lines * 21 + 16


highlight : String -> Parameters -> String -> String -> Html Msg
highlight theme attr lang code =
    let
        readOnly =
            if Params.get "data-readonly" attr == Nothing then
                True

            else
                Params.isSet "data-readonly" attr
    in
    Editor.editor
        (attr
            |> Params.toAttribute
            |> List.append
                [ Editor.value code
                , Editor.mode lang
                , attr
                    |> Params.get "data-theme"
                    |> Maybe.withDefault theme
                    |> Editor.theme
                , attr
                    |> Params.get "data-tabsize"
                    |> Maybe.andThen String.toInt
                    |> Maybe.withDefault 2
                    |> Editor.tabSize
                , attr
                    |> Params.get "data-marker"
                    |> Maybe.withDefault ""
                    |> Editor.marker
                , attr
                    |> Params.get "data-firstlinenumber"
                    |> Maybe.andThen String.toInt
                    |> Maybe.withDefault 1
                    |> Editor.firstLineNumber
                , Editor.useSoftTabs False
                , Editor.readOnly readOnly
                , Editor.showCursor (not readOnly)
                , Editor.highlightActiveLine False
                , attr
                    |> Params.isSet "data-showgutter"
                    |> Editor.showGutter
                , Editor.showPrintMargin False
                , attr
                    |> Params.get "data-fontsize"
                    |> Maybe.withDefault "1.5rem"
                    |> Editor.fontSize
                ]
        )
        []


evaluate : String -> Parameters -> Bool -> ( Int, Int ) -> File -> JE.Value -> Html Msg
evaluate theme attr running ( id_1, id_2 ) file errors =
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
            if running then
                running

            else
                attr
                    |> Params.isSet "data-readonly"
    in
    Editor.editor
        (attr
            |> Params.toAttribute
            |> List.append
                (max_lines
                    |> pixel
                    |> toStyle file.visible
                )
            |> List.append
                [ Editor.onChange <| Update id_1 id_2
                , Editor.value file.code
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
                , if Params.get "data-showgutter" attr /= Nothing then
                    attr
                        |> Params.isSet "data-showgutter"
                        |> Editor.showGutter

                  else
                    Editor.showGutter True
                , Editor.useSoftTabs False
                , Editor.annotations errors
                , Editor.enableBasicAutocompletion True
                , Editor.enableLiveAutocompletion True
                , Editor.enableSnippets True
                , Editor.extensions [ "language_tools" ]
                ]
        )
        []


view_result : Log -> Html msg
view_result log =
    if Array.isEmpty log.messages then
        Html.text ""

    else
        Log.view log
            |> Keyed.node "pre"
                [ Attr.class "lia-code-terminal__output"
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


view_control : Lang -> Int -> Int -> Int -> Bool -> Bool -> Html Msg
view_control lang idx version_active version_count running terminal =
    let
        forward =
            running || (version_active == 0)

        backward =
            running || (version_active == (version_count - 1))
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
                        , msg = Just <| Stop idx
                        , tabbable = True
                        , icon = "icon-stop-circle"
                        }
                        [ Attr.class "lia-btn--transparent" ]

                _ ->
                    btnIcon
                        { title = codeExecute lang
                        , msg = Just <| Eval idx
                        , tabbable = True
                        , icon = "icon-compile-circle"
                        }
                        [ Attr.class "lia-btn--transparent" ]
            ]
        , Html.div [ Attr.class "lia-code-control__version" ]
            [ btnIcon
                { title = codeFirst lang
                , tabbable = not forward
                , msg =
                    if not forward then
                        Just <| First idx

                    else
                        Nothing
                , icon = "icon-end-left"
                }
                [ Attr.class "lia-btn--transparent" ]
            , btnIcon
                { title = codePrev lang
                , tabbable = not forward
                , msg =
                    if not forward then
                        Just <| Load idx (version_active - 1)

                    else
                        Nothing
                , icon = "icon-chevron-left"
                }
                [ Attr.class "lia-btn--transparent" ]
            , Html.span
                [ Attr.class "lia-label"
                ]
                [ Html.text (String.fromInt version_active) ]
            , btnIcon
                { title = codeNext lang
                , tabbable = not backward
                , msg =
                    if not backward then
                        Just <| Load idx (version_active + 1)

                    else
                        Nothing
                , icon = "icon-chevron-right"
                }
                [ Attr.class "lia-btn--transparent" ]
            , btnIcon
                { title = codeLast lang
                , tabbable = not backward
                , msg =
                    if not backward then
                        Just <| Last idx

                    else
                        Nothing
                , icon = "icon-end-right"
                }
                [ Attr.class "lia-btn--transparent" ]
            ]
        ]
