module Lia.Markdown.Code.View exposing (view)

--import Lia.Ace as Ace

import Array
import Html exposing (Html)
import Html.Attributes as Attr exposing (attribute, lang)
import Html.Events exposing (onClick, onInput)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Event as Event
import Lia.Markdown.Code.Editor as Editor
import Lia.Markdown.Code.Terminal as Terminal
import Lia.Markdown.Code.Types exposing (..)
import Lia.Markdown.Code.Update exposing (Msg(..))
import Lia.Markdown.Inline.Types exposing (Annotation)
import Lia.Markdown.Inline.View exposing (annotation, attributes)
import Translations exposing (Lang, codeExecute, codeFirst, codeLast, codeMaximize, codeMinimize, codeNext, codePrev, codeRunning)


view : Lang -> String -> Annotation -> Vector -> Code -> Html Msg
view lang theme attr model code =
    case code of
        Highlight lang_title_code ->
            lang_title_code
                |> List.map (view_code theme attr)
                |> div_

        Evaluate id_1 ->
            case Array.get id_1 model of
                Just project ->
                    let
                        errors =
                            get_annotations project.log
                    in
                    div_
                        [ project.file
                            |> Array.indexedMap (view_eval lang theme attr project.running errors id_1)
                            |> Array.toList
                            |> Html.div []
                        , view_control lang
                            id_1
                            project.version_active
                            (Array.length project.version)
                            project.running
                            (if project.terminal == Nothing then
                                False

                             else
                                True
                            )
                        , view_result project.log
                        , case project.terminal of
                            Nothing ->
                                Html.text ""

                            Just term ->
                                term
                                    |> Terminal.view
                                    |> Html.map (UpdateTerminal id_1)
                        ]

                Nothing ->
                    Html.text ""


get_annotations : Event.Eval -> Int -> JE.Value
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


div_ : List (Html msg) -> Html msg
div_ =
    Html.div
        [ Attr.style "margin-top" "16px"
        , Attr.style "margin-bottom" "16px"
        ]


view_code : String -> Annotation -> Snippet -> Html Msg
view_code theme attr snippet =
    let
        headless =
            snippet.name == ""
    in
    Html.div []
        [ if headless then
            Html.text ""

          else
            Html.button
                [ Attr.class "lia-accordion-dummy" ]
                [ Html.text snippet.name
                ]
        , highlight theme attr snippet.lang snippet.code headless
        ]


view_eval : Lang -> String -> Annotation -> Bool -> (Int -> JE.Value) -> Int -> Int -> File -> Html Msg
view_eval lang theme attr running errors id_1 id_2 file =
    let
        headless =
            file.name == ""
    in
    Html.div (annotation "" attr)
        [ if headless then
            Html.text ""

          else
            Html.div
                [ Attr.classList
                    [ ( "lia-accordion", True )
                    , ( "active", file.visible )
                    ]
                ]
                [ Html.span
                    [ onClick <| FlipView id_1 id_2
                    , Attr.style "width" "calc(100% - 20px)"
                    , Attr.style "display" "inline-block"
                    ]
                    [ Html.b []
                        [ if file.visible then
                            Html.text " + "

                          else
                            Html.text " - "
                        ]
                    , Html.text file.name
                    ]
                , if file.visible then
                    Html.span
                        [ Attr.class "lia-accordion-min-max"
                        , onClick <| FlipFullscreen id_1 id_2
                        , Attr.title <|
                            if file.fullscreen then
                                codeMinimize lang

                            else
                                codeMaximize lang
                        ]
                        [ Html.b []
                            [ if file.fullscreen then
                                Html.text "↥"

                              else
                                Html.text "↧"
                            ]
                        ]

                  else
                    Html.text ""
                ]
        , evaluate theme attr running ( id_1, id_2 ) file headless (errors id_2)
        ]


toStyle : Bool -> Bool -> Int -> List (Html.Attribute msg)
toStyle visible headless pix =
    let
        top_border =
            if headless then
                "4px"

            else
                "0px"
    in
    [ Attr.style "max-height"
        (if visible then
            String.fromInt pix ++ "px"

         else
            "0px"
        )
    , Attr.style "transition" "max-height 0.25s ease-out"
    , Attr.style "border-bottom-left-radius" "4px"
    , Attr.style "border-bottom-right-radius" "4px"
    , Attr.style "border-top-left-radius" top_border
    , Attr.style "border-top-right-radius" top_border
    , Attr.style "border" "1px solid gray"
    ]


lines : String -> Int
lines code =
    code
        |> String.lines
        |> List.length


pixel : Int -> Int
pixel from_lines =
    from_lines * 21 + 16


highlight : String -> Annotation -> String -> String -> Bool -> Html Msg
highlight theme attr lang code headless =
    let
        top_border =
            if headless then
                "4px"

            else
                "0px"
    in
    Editor.editor
        (attr
            |> attributes
            |> List.append
                [ Attr.style "border-bottom-left-radius" "4px"
                , Attr.style "border-bottom-right-radius" "4px"
                , Attr.style "border-top-left-radius" top_border
                , Attr.style "border-top-right-radius" top_border
                , Attr.style "border" "1px solid gray"
                , Editor.value code
                , Editor.mode lang
                , Editor.theme theme
                , Editor.tabSize 2
                , Editor.useSoftTabs False
                , Editor.readOnly True
                , Editor.showCursor False
                , Editor.highlightActiveLine False
                , Editor.showGutter False
                , Editor.showPrintMargin False
                ]
        )
        []


evaluate : String -> Annotation -> Bool -> ( Int, Int ) -> File -> Bool -> JE.Value -> Html Msg
evaluate theme attr running ( id_1, id_2 ) file headless errors =
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
    in
    Editor.editor
        (attr
            |> attributes
            |> List.append
                (max_lines
                    |> pixel
                    |> toStyle file.visible headless
                )
            |> List.append
                [ Editor.onChange <| Update id_1 id_2
                , Editor.value file.code
                , Editor.mode file.lang
                , Editor.theme theme
                , Editor.maxLines
                    (if max_lines > 16 then
                        -1

                     else
                        max_lines
                    )
                , Editor.readOnly running
                , Editor.tabSize 2
                , Editor.useSoftTabs False
                , Editor.annotations errors
                , Editor.enableBasicAutocompletion True
                , Editor.enableLiveAutocompletion True
                , Editor.enableSnippets True
                , Editor.extensions [ "language_tools" ]
                ]
        )
        []


error : String -> Html msg
error info =
    Html.pre
        [ Attr.class "lia-code-stdout"
        , Attr.style "color" "red"
        , scroll_to_end info
        ]
        [ Html.text info ]


view_result : Event.Eval -> Html msg
view_result log =
    if log.ok then
        if log.result == "" then
            Html.div [ Attr.style "margin-top" "8px" ] []

        else
            Html.pre
                [ Attr.class "lia-code-stdout"
                , scroll_to_end log.result
                ]
                [ Html.text log.result ]

    else
        error log.result


scroll_to_end : String -> Html.Attribute msg
scroll_to_end output =
    output
        |> String.lines
        |> List.length
        |> (*) 14
        |> (+) 14
        |> String.fromInt
        |> JE.string
        |> Attr.property "scrollTop"


control_style : List (Html.Attribute msg)
control_style =
    [ Attr.style "padding-left" "5px"
    , Attr.style "padding-right" "5px"
    , Attr.style "float" "right"
    , Attr.style "margin-right" "2px"
    , Attr.style "margin-left" "2px"
    ]


view_control : Lang -> Int -> Int -> Int -> Bool -> Bool -> Html Msg
view_control lang idx version_active version_count running terminal =
    let
        forward =
            running || (version_active == 0)

        backward =
            running || (version_active == (version_count - 1))
    in
    Html.div [ Attr.style "padding" "0px", Attr.style "width" "100%" ]
        [ case ( running, terminal ) of
            ( True, False ) ->
                Html.span
                    [ Attr.class "lia-btn lia-icon"
                    , Attr.style "margin-left" "0px"
                    , Attr.title (codeRunning lang)
                    , Attr.disabled True
                    ]
                    [ Html.span
                        [ Attr.class "lia-icon rotating"
                        ]
                        [ Html.text "sync" ]
                    ]

            ( True, True ) ->
                Html.span
                    [ Attr.class "lia-btn lia-icon"
                    , Attr.style "margin-left" "0px"
                    , Attr.title (codeRunning lang)
                    , onClick (Stop idx)
                    ]
                    [ Html.text "stop" ]

            _ ->
                Html.span
                    [ Attr.class "lia-btn lia-icon"
                    , onClick (Eval idx)
                    , Attr.style "margin-left" "0px"
                    , Attr.title (codeExecute lang)
                    ]
                    [ Html.text "play_circle_filled" ]
        , Html.button
            (List.append control_style
                [ Last idx |> onClick
                , Attr.class "lia-btn lia-icon"
                , Attr.title (codeLast lang)
                , Attr.disabled backward
                ]
            )
            [ Html.text "last_page" ]
        , Html.button
            (List.append control_style
                [ (version_active + 1) |> Load idx |> onClick
                , Attr.class "lia-btn lia-icon"
                , Attr.title (codeNext lang)
                , Attr.disabled backward
                ]
            )
            [ Html.text "navigate_next" ]
        , Html.span
            [ Attr.class "lia-label"
            , Attr.style "float" "right"
            , Attr.style "margin-top" "11px"
            ]
            [ Html.text (String.fromInt version_active) ]
        , Html.button
            (List.append control_style
                [ (version_active - 1) |> Load idx |> onClick
                , Attr.class "lia-btn lia-icon"
                , Attr.title (codePrev lang)
                , Attr.disabled forward
                ]
            )
            [ Html.text "navigate_before" ]
        , Html.button
            (List.append control_style
                [ First idx |> onClick
                , Attr.class "lia-btn lia-icon"
                , Attr.title (codeFirst lang)
                , Attr.disabled forward
                ]
            )
            [ Html.text "first_page" ]
        ]
