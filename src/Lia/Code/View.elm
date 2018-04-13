module Lia.Code.View exposing (error, view)

import Array
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onDoubleClick, onInput)
import Lia.Code.Types exposing (Code(..), Vector)
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
                        , Html.div []
                            [ if elem.running then
                                Html.button [ Attr.class "lia-btn lia-icon" ]
                                    [ Html.text "sync" ]
                              else
                                Html.button [ Attr.class "lia-btn lia-icon", onClick (Eval idx x) ]
                                    [ Html.text "play_circle_filled" ]
                            , Html.span [ Attr.class "lia-spacer" ] []
                            , Html.button
                                [ (elem.version_active - 1)
                                    |> Load idx
                                    |> onClick
                                , Attr.class "lia-btn lia-icon lia-left"
                                ]
                                [ Html.text "navigate_before" ]
                            , Html.span [ Attr.class "lia-label lia-left" ] [ Html.text (toString elem.version_active) ]
                            , Html.button
                                [ (elem.version_active + 1)
                                    |> Load idx
                                    |> onClick
                                , Attr.class "lia-btn lia-icon lia-left"
                                ]
                                [ Html.text "navigate_next" ]
                            , Html.div
                                [ Attr.style
                                    [ ( "max-height", "250px" )
                                    , ( "overflow", "auto" )
                                    ]
                                ]
                                [ case elem.result of
                                    Ok rslt ->
                                        Html.pre [] [ Lia.Utils.stringToHtml rslt ]

                                    Err rslt ->
                                        error rslt
                                ]
                            ]
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
    Html.pre [ Attr.style [ ( "color", "red" ) ] ] [ Html.text ("Error: " ++ info) ]
