module Lia.Code.View exposing (error, view)

import Array
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onDoubleClick, onInput)
import Lia.Code.Types exposing (Code(..), EvalString, Vector)
import Lia.Code.Update exposing (Msg(..))
import Lia.Helper exposing (ID)
import Lia.Markdown.Inline.Types exposing (Annotation)
import Lia.Markdown.Inline.View exposing (annotation)
import Lia.Utils


view : Annotation -> Vector -> Code -> Html Msg
view attr model code =
    case code of
        Highlight lang_title_code ->
            lang_title_code
                |> List.map (hh1 attr)
                |> Html.div [ Attr.style [ ( "margin-top", "16px" ), ( "margin-bottom", "16px" ) ] ]

        Evaluate idx ->
            case Array.get idx model of
                Just project ->
                    Html.div [ Attr.style [ ( "margin-top", "16px" ), ( "margin-bottom", "16px" ) ] ]
                        [ project.file
                            |> Array.indexedMap (\id_2 file -> hh2 attr idx id_2 file)
                            |> Array.toList
                            |> Html.div []
                        , view_control idx project.version_active project.running
                        , view_result project.result
                        ]

                Nothing ->
                    Html.text ""


hh1 attr ( lang, title, code ) =
    let
        headless =
            title == ""
    in
    Html.div []
        [ if headless then
            Html.text ""
          else
            Html.button
                [ Attr.classList
                    [ ( "lia-accordion", True )
                    , ( "active", True )
                    ]
                ]
                [ Html.text title ]
        , highlight attr lang code -1 -1 True headless
        ]


hh2 attr id_1 id_2 file =
    let
        headless =
            file.name == ""
    in
    Html.div []
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
        , if file.editing then
            Html.textarea
                (List.append
                    (annotation attr "lia-input")
                    [ Attr.style [ ( "width", "100%" ), ( "overflow", "auto" ) ]
                    , file.code |> String.lines |> List.length |> Attr.rows
                    , onInput <| Update id_1 id_2
                    , Attr.value file.code
                    , Attr.wrap "off"
                    , onDoubleClick (FlipMode id_1 id_2)
                    ]
                )
                []
          else
            highlight attr file.lang file.code id_1 id_2 file.visible headless
        ]


highlight : Annotation -> String -> String -> ID -> ID -> Bool -> Bool -> Html Msg
highlight attr lang code id_1 id_2 visible headless =
    Html.pre
        (if id_1 < 0 then
            annotation attr
                ("lia-code"
                    ++ (if headless then
                            " headless"
                        else
                            ""
                       )
                )
         else
            onDoubleClick (FlipMode id_1 id_2)
                :: Attr.style
                    [ ( "max-height"
                      , if visible then
                            "250px"
                        else
                            "0px"
                      )
                    ]
                :: annotation attr
                    ("lia-code"
                        ++ (if headless then
                                " headless"
                            else
                                ""
                           )
                    )
        )
        [ Html.code
            [ Attr.class "lia-code-highlight"
            ]
            [ Lia.Utils.highlight lang code ]
        ]


error : String -> Html msg
error info =
    Html.pre
        [ Attr.class "lia-code-stdout"
        , Attr.style [ ( "color", "red" ) ]
        ]
        [ Html.text ("Error: " ++ info) ]


view_result : Result String String -> Html msg
view_result rslt =
    case rslt of
        Ok str ->
            if str == "" then
                Html.div [ Attr.style [ ( "margin-top", "8px" ) ] ] []
            else
                Html.pre [ Attr.class "lia-code-stdout" ] [ Lia.Utils.stringToHtml str ]

        Err str ->
            error str


view_control : ID -> Int -> Bool -> Html Msg
view_control idx version_active running =
    Html.div [ Attr.style [ ( "padding", "0px" ), ( "width", "100%" ) ] ]
        [ if running then
            Html.button
                [ Attr.class "lia-btn lia-icon"
                , Attr.style [ ( "margin-left", "0px" ) ]
                ]
                [ Html.text "sync" ]
          else
            Html.button
                [ Attr.class "lia-btn lia-icon"
                , onClick (Eval idx)
                , Attr.style [ ( "margin-left", "0px" ) ]
                ]
                [ Html.text "play_circle_filled" ]
        , Html.button
            [ (version_active + 1) |> Load idx |> onClick
            , Attr.class "lia-btn lia-icon"
            , Attr.style [ ( "float", "right" ), ( "margin-right", "0px" ) ]
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
            ]
            [ Html.text "navigate_before" ]
        ]
