module Lia.Markdown.Quiz.MultipleChoiceMatrix.View exposing (view)

import Array exposing (Array)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (view_inf)
import Lia.Markdown.Quiz.MultipleChoiceMatrix.Types exposing (Quiz, State)
import Lia.Markdown.Quiz.MultipleChoiceMatrix.Update exposing (Msg(..))


view : Bool -> Quiz -> State -> Html Msg
view solved quiz state =
    state
        |> Array.toList
        |> List.indexedMap (tr solved)
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


tr : Bool -> Int -> Array Bool -> List (Html Msg)
tr solved id array =
    array
        |> Array.toList
        |> List.indexedMap (td solved id)


td : Bool -> Int -> Int -> Bool -> Html Msg
td solved row_id column_id value =
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


add_text : Inlines -> List (Html Msg) -> Html Msg
add_text inline toRow =
    inline
        |> List.map view_inf
        |> Html.td []
        |> List.singleton
        |> List.append toRow
        |> Html.tr []
