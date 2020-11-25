module Lia.Markdown.Quiz.Matrix.View exposing (view)

import Array
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Quiz.Matrix.Types exposing (Quiz, State)
import Lia.Markdown.Quiz.Matrix.Update exposing (Msg(..))
import Lia.Markdown.Quiz.Vector.Types as Vector


view : Config sub -> Bool -> Quiz -> State -> Html (Msg sub)
view config solved quiz state =
    state
        |> Array.toList
        |> List.indexedMap (tr solved)
        |> List.map2 (add_text config) quiz.options
        |> (::) (header config quiz.headers)
        |> Html.table [ Attr.class "lia-survey-matrix" ]


header : Config sub -> List Inlines -> Html (Msg sub)
header config inlines =
    inlines
        |> List.map (th config)
        |> Html.tr [ Attr.class "lia-label" ]


th : Config sub -> Inlines -> Html (Msg sub)
th config =
    viewer config
        >> Html.th [ Attr.align "center" ]
        >> Html.map Script


tr : Bool -> Int -> Vector.State -> List (Html (Msg sub))
tr solved id state =
    case state of
        Vector.SingleChoice list ->
            list |> List.indexedMap (radio solved id)

        Vector.MultipleChoice list ->
            list |> List.indexedMap (check solved id)


radio : Bool -> Int -> Int -> Bool -> Html (Msg sub)
radio solved row_id column_id value =
    Html.td [ Attr.align "center" ]
        [ Html.span
            [ Attr.class "lia-radio-item" ]
            [ Html.input
                [ Attr.type_ "radio"
                , Attr.checked value
                , if solved then
                    Attr.disabled True

                  else
                    onClick <| Toggle row_id column_id
                ]
                []
            , Html.span
                [ Attr.class "lia-radio-btn" ]
                [ Html.text ""
                ]
            ]
        ]


check : Bool -> Int -> Int -> Bool -> Html (Msg sub)
check solved row_id column_id value =
    Html.td [ Attr.align "center" ]
        [ Html.span
            [ Attr.class "lia-check-item" ]
            [ Html.input
                [ Attr.type_ "checkbox"
                , Attr.checked value
                , if solved then
                    Attr.disabled True

                  else
                    onClick <| Toggle row_id column_id
                ]
                []
            , Html.span
                [ Attr.class "lia-check-btn" ]
                [ Html.text "check"
                ]
            ]
        ]


add_text : Config sub -> Inlines -> List (Html (Msg sub)) -> Html (Msg sub)
add_text config inline toRow =
    inline
        |> viewer config
        |> Html.td []
        |> Html.map Script
        |> List.singleton
        |> List.append toRow
        |> Html.tr []
