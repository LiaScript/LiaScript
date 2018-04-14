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
        Highlight lang title block ->
            Html.div []
                [ Html.button [] [ Html.text title ]
                , highlight attr lang block -1 True
                ]

        Evaluate lang title idx x ->
            case Array.get idx model of
                Just elem ->
                    Html.div []
                        [ Html.button
                            [ onClick <| FlipView idx
                            , Attr.classList
                                [ ( "lia-accordion", True )
                                , ( "active", elem.visible )
                                ]
                            ]
                            [ Html.text title ]
                        , if elem.editing then
                            Html.textarea
                                (List.append
                                    (annotation attr "lia-input")
                                    [ Attr.style [ ( "width", "100%" ), ( "overflow", "auto" ) ]
                                    , elem.code |> String.lines |> List.length |> Attr.rows
                                    , onInput <| Update idx
                                    , Attr.value elem.code
                                    , Attr.wrap "off"
                                    , onDoubleClick (FlipMode idx)
                                    ]
                                )
                                []
                          else
                            highlight attr lang elem.code idx elem.visible
                        , view_control idx x elem.version_active elem.running
                        , view_result elem.result
                        ]

                Nothing ->
                    Html.text ""


highlight : Annotation -> String -> String -> ID -> Bool -> Html Msg
highlight attr lang code idx visible =
    Html.pre
        (if idx < 0 then
            annotation attr "lia-code"
         else
            onDoubleClick (FlipMode idx)
                :: Attr.style
                    [ ( "max-height"
                      , if visible then
                            "250px"
                        else
                            "0px"
                      )
                    ]
                :: annotation attr "lia-code"
        )
        [ Html.code [ Attr.class "lia-code-highlight" ]
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


view_control : ID -> EvalString -> Int -> Bool -> Html Msg
view_control idx x version_active running =
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
                , onClick (Eval idx x)
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
