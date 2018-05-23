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
import Translations exposing (Lang, codeExecute, codeNext, codePrev, codeRunning)


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
                            |> Array.indexedMap (view_eval theme attr project.running errors id_1)
                            |> Array.toList
                            |> Html.div []
                        , view_control lang id_1 project.version_active project.running
                        , view_result project.result
                        ]

                Nothing ->
                    Html.text ""


get_annotations : Result Rslt Rslt -> ID -> JE.Value
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
                [ Attr.class "lia-accordion active" ]
                [ Html.text title ]
        , highlight theme attr lang code headless
        ]


view_eval : String -> Annotation -> Bool -> (ID -> JE.Value) -> ID -> ID -> File -> Html Msg
view_eval theme attr running errors id_1 id_2 file =
    let
        headless =
            file.name == ""
    in
    Html.div (annotation "" attr)
        [ if headless then
            Html.text ""
          else
            Html.button
                [ onClick <| FlipView id_1 id_2
                , Attr.classList
                    [ ( "lia-accordion", True )
                    , ( "active", file.visible )
                    ]
                ]
                [ Html.text file.name ]
        , evaluate theme running ( id_1, id_2 ) file.lang file.code file.visible headless (errors id_2)
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
    [ ( "height", height_str )
    , ( "font-size", "13px" )
    , ( "max-height"
      , if visible then
            height_str
        else
            "0px"
      )
    , ( "font-family", "monospace" )
    , ( "transition", "max-height 0.5s ease-out" )
    , ( "border-bottom-left-radius", "4px" )
    , ( "border-bottom-right-radius", "4px" )
    , ( "border-top-left-radius", top_border )
    , ( "border-top-right-radius", top_border )
    ]


lines : String -> Int
lines code =
    code
        |> String.lines
        |> List.length


pixel : Int -> Int
pixel lines =
    lines * 16 + 16


highlight : String -> Annotation -> String -> String -> Bool -> Html Msg
highlight theme attr lang code headless =
    Ace.toHtml
        [ Ace.value code
        , Ace.mode lang
        , Ace.theme theme
        , Ace.tabSize 2
        , Ace.useSoftTabs False
        , Ace.readOnly True
        , Ace.showCursor False
        , Ace.highlightActiveLine False
        , Ace.showGutter False
        , Ace.showPrintMargin False
        , code |> lines |> pixel |> style True headless |> Attr.style
        ]
        []


evaluate : String -> Bool -> ( ID, ID ) -> String -> String -> Bool -> Bool -> JE.Value -> Html Msg
evaluate theme running ( id_1, id_2 ) lang code visible headless errors =
    let
        total_lines =
            lines code

        max_lines =
            if total_lines > 16 then
                16
            else
                total_lines

        style_ =
            max_lines
                |> pixel
                |> style visible headless
    in
    Html.div []
        [ Ace.toHtml
            [ Ace.onSourceChange <| Update id_1 id_2
            , Ace.value code
            , Ace.mode lang
            , Ace.theme theme
            , Ace.readOnly running
            , Ace.enableBasicAutocompletion True
            , Ace.enableLiveAutocompletion True
            , Ace.enableSnippets True
            , Ace.tabSize 2
            , Ace.useSoftTabs False
            , Ace.extensions [ "language_tools" ]
            , Attr.style style_
            , Ace.maxLines 16
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
        [ Html.text ("Error: " ++ info) ]


view_result : Result Rslt Rslt -> Html msg
view_result rslt =
    case rslt of
        Ok info ->
            if info.message == "" then
                Html.div [ Attr.style [ ( "margin-top", "8px" ) ] ] []
            else
                Html.pre [ Attr.class "lia-code-stdout" ] [ Lia.Utils.stringToHtml info.message ]

        Err info ->
            error info.message


view_control : Lang -> ID -> Int -> Bool -> Html Msg
view_control lang idx version_active running =
    Html.div [ Attr.style [ ( "padding", "0px" ), ( "width", "100%" ) ] ]
        [ if running then
            Html.button
                [ Attr.class "lia-btn lia-icon"
                , Attr.style [ ( "margin-left", "0px" ) ]
                , Attr.title (codeRunning lang)
                ]
                [ Html.text "sync" ]
          else
            Html.button
                [ Attr.class "lia-btn lia-icon"
                , onClick (Eval idx)
                , Attr.style [ ( "margin-left", "0px" ) ]
                , Attr.title (codeExecute lang)
                ]
                [ Html.text "play_circle_filled" ]
        , Html.button
            [ (version_active + 1) |> Load idx |> onClick
            , Attr.class "lia-btn lia-icon"
            , Attr.style [ ( "float", "right" ), ( "margin-right", "0px" ) ]
            , Attr.title (codeNext lang)
            ]
            [ Html.text "navigate_next" ]
        , Html.span
            [ Attr.class "lia-label"
            , Attr.style [ ( "float", "right" ) ]
            ]
            [ Html.text (toString version_active) ]
        , Html.button
            [ (version_active - 1) |> Load idx |> onClick
            , Attr.class "lia-btn lia-icon"
            , Attr.style [ ( "float", "right" ) ]
            , Attr.title (codePrev lang)
            ]
            [ Html.text "navigate_before" ]
        ]
