module Lia.Markdown.Quiz.SingleChoiceMatrix.View exposing (view)

import Array exposing (Array)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (view_inf)
import Lia.Markdown.Quiz.SingleChoiceMatrix.Types exposing (Quiz, State)
import Lia.Markdown.Quiz.SingleChoiceMatrix.Update exposing (Msg(..))


view : Bool -> Quiz -> State -> Html Msg
view solved quiz state =
    state
        |> Array.toList
        |> List.indexedMap (tr quiz.size solved)
        |> List.map2 add_text quiz.options
        |> (::) (header quiz.headers)
        |> Html.table [ Attr.class "lia-survey-matrix" ]


header : List Inlines -> Html Msg
header inlines =
    inlines
        |> List.map th
        |> Html.tr [ Attr.class "lia-label" ]


th : Inlines -> Html Msg
th inlines =
    inlines
        |> List.map view_inf
        |> Html.th [ Attr.align "center" ]


tr : Int -> Bool -> Int -> Int -> List (Html Msg)
tr size solved id value =
    size
        |> List.range 0
        |> List.map (td solved id value)


td : Bool -> Int -> Int -> Int -> Html Msg
td solved row_id value column_id =
    Html.td [ Attr.align "center" ]
        [ Html.span
            [ Attr.class "lia-radio-item" ]
            [ Html.input
                [ Attr.type_ "radio"
                , Attr.checked (value == column_id)
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


add_text : Inlines -> List (Html Msg) -> Html Msg
add_text inline toRow =
    inline
        |> List.map view_inf
        |> Html.td []
        |> List.singleton
        |> List.append toRow
        |> Html.tr []
