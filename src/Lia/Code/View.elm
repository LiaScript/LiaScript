module Lia.Code.View exposing (error, view)

import Array
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onDoubleClick, onInput)
import Json.Encode as JE
import Lia.Ace as Ace
import Lia.Code.Types exposing (..)
import Lia.Code.Update exposing (Msg(..))
import Lia.Helper exposing (ID)
import Lia.Markdown.Inline.Types exposing (Annotation)
import Lia.Markdown.Inline.View exposing (annotation)
import Lia.Utils
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
                            get_annotations project.result
                    in
                    div_
                        [ project.file
                            |> Array.indexedMap (view_eval lang theme attr project.running errors id_1)
                            |> Array.toList
                            |> Html.div []
                        , view_control lang id_1 project.version_active project.running
                        , view_result project.result
                        ]

                Nothing ->
                    Html.text ""


get_annotations : Result Log Log -> ID -> JE.Value
get_annotations rslt file_id =
    (case rslt of
        Ok info ->
            info.details

        Err info ->
            info.details
    )
        |> Array.get file_id
        |> Maybe.withDefault JE.null


div_ : List (Html msg) -> Html msg
div_ =
    Html.div
        [ Attr.style
            [ ( "margin-top", "16px" )
            , ( "margin-bottom", "16px" )
            ]
        ]


view_code : String -> Annotation -> ( String, String, String ) -> Html Msg
view_code theme attr ( lang, title, code ) =
    let
        headless =
            title == ""
    in
    Html.div (annotation "" attr)
        [ if headless then
            Html.text ""

          else
            Html.button
                [ Attr.class "lia-accordion-dummy" ]
                [ Html.text title
                ]
        , highlight theme attr lang code headless
        ]


view_eval : Lang -> String -> Annotation -> Bool -> (ID -> JE.Value) -> ID -> ID -> File -> Html Msg
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
                    , Attr.style [ ( "width", "calc(100% - 18px)" ), ( "display", "inline-block" ) ]
                    ]
                    [ if file.visible then
                        Html.b [] [ Html.text " + " ]

                      else
                        Html.b [] [ Html.text " - " ]
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
        , evaluate theme running ( id_1, id_2 ) file headless (errors id_2)
        ]


style : Bool -> Bool -> Int -> List ( String, String )
style visible headless height_ =
    let
        height_str =
            toString height_ ++ "px"

        top_border =
            if headless then
                "4px"

            else
                "0px"
    in
    [ ( "font-size", "13px" )
    , ( "overflow", "auto" )
    , ( "max-height"
      , if visible then
            height_str

        else
            "0px"
      )
    , ( "font-family", "monospace" )
    , ( "transition", "max-height 0.25s ease-out" )
    , ( "border-bottom-left-radius", "4px" )
    , ( "border-bottom-right-radius", "4px" )
    , ( "border-top-left-radius", top_border )
    , ( "border-top-right-radius", top_border )
    , ( "border", "1px solid gray" )
    ]


lines : String -> Int
lines code =
    code
        |> String.lines
        |> List.length


pixel : Int -> Int
pixel lines =
    lines * 13 + 17


highlight : String -> Annotation -> String -> String -> Bool -> Html Msg
highlight theme attr lang code headless =
    Html.div [ code |> lines |> pixel |> style True headless |> Attr.style ]
        [ Ace.toHtml
            [ Ace.value code
            , Ace.mode lang
            , Ace.theme theme
            , Ace.tabSize 2
            , Ace.useSoftTabs False
            , Ace.readOnly True
            , Ace.showCursor False
            , Ace.highlightActiveLine False
            , Ace.showGutter True
            , Ace.showPrintMargin False
            ]
            []
        ]


evaluate : String -> Bool -> ( ID, ID ) -> File -> Bool -> JE.Value -> Html Msg
evaluate theme running ( id_1, id_2 ) file headless errors =
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

        style_ =
            max_lines
                |> pixel
                |> style file.visible headless
    in
    Html.div [ Attr.style style_ ]
        [ Ace.toHtml
            [ Ace.onSourceChange <| Update id_1 id_2
            , Ace.value file.code
            , Ace.mode file.lang
            , Ace.theme theme
            , Ace.readOnly running
            , Ace.enableBasicAutocompletion True
            , Ace.enableLiveAutocompletion True
            , Ace.enableSnippets True
            , Ace.tabSize 2
            , Ace.useSoftTabs False
            , Ace.extensions [ "language_tools" ]
            , Ace.annotations errors
            ]
            []
        ]


error : String -> Html msg
error info =
    Html.pre
        [ Attr.class "lia-code-stdout"
        , Attr.style [ ( "color", "red" ) ]
        ]
        [ Html.text info ]


view_result : Result Log Log -> Html msg
view_result rslt =
    case rslt of
        Ok info ->
            if info.message == "" then
                Html.div [ Attr.style [ ( "margin-top", "8px" ) ] ] []

            else
                Html.pre [ Attr.class "lia-code-stdout" ] [ Lia.Utils.stringToHtml info.message ]

        Err info ->
            error info.message


control_style : Html.Attribute msg
control_style =
    Attr.style
        [ ( "padding-left", "5px" )
        , ( "padding-right", "5px" )
        , ( "float", "right" )
        , ( "margin-right", "2px" )
        , ( "margin-left", "2px" )
        ]


view_control : Lang -> ID -> Int -> Bool -> Html Msg
view_control lang idx version_active running =
    Html.div [ Attr.style [ ( "padding", "0px" ), ( "width", "100%" ) ] ]
        [ if running then
            Html.span
                [ Attr.class "lia-btn lia-icon"
                , Attr.style [ ( "margin-left", "0px" ) ]
                , Attr.title (codeRunning lang)
                ]
                [ Html.text "sync" ]

          else
            Html.span
                [ Attr.class "lia-btn lia-icon"
                , onClick (Eval idx)
                , Attr.style [ ( "margin-left", "0px" ) ]
                , Attr.title (codeExecute lang)
                ]
                [ Html.text "play_circle_filled" ]
        , Html.button
            [ Last idx |> onClick
            , Attr.class "lia-btn lia-icon"
            , control_style
            , Attr.title (codeLast lang)
            ]
            [ Html.text "last_page" ]
        , Html.button
            [ (version_active + 1) |> Load idx |> onClick
            , Attr.class "lia-btn lia-icon"

            --, Attr.style [ ( "float", "right" ), ( "margin-right", "0px" ) ]
            , control_style
            , Attr.title (codeNext lang)
            ]
            [ Html.text "navigate_next" ]
        , Html.span
            [ Attr.class "lia-label"
            , Attr.style
                [ ( "float", "right" )
                , ( "margin-top", "11px" )
                ]
            ]
            [ Html.text (toString version_active) ]
        , Html.button
            [ (version_active - 1) |> Load idx |> onClick
            , Attr.class "lia-btn lia-icon"
            , control_style
            , Attr.title (codePrev lang)
            ]
            [ Html.text "navigate_before" ]
        , Html.button
            [ First idx |> onClick
            , Attr.class "lia-btn lia-icon"
            , control_style
            , Attr.title (codeFirst lang)
            ]
            [ Html.text "first_page" ]
        ]
