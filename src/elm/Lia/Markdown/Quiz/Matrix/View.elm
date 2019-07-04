module Lia.Markdown.Quiz.Matrix.View exposing (view)

import Array exposing (Array)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (view_inf)
import Lia.Markdown.Quiz.Matrix.Types exposing (Quiz, State)
import Lia.Markdown.Quiz.Matrix.Update exposing (Msg(..))
import Lia.Markdown.Quiz.Vector.Types as Vector


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


tr : Bool -> Int -> Vector.State -> List (Html Msg)
tr solved id state =
    case state of
        Vector.SingleChoice size value ->
            size
                |> List.range 0
                |> List.map (radio solved id value)

        Vector.MultipleChoice array ->
            array
                |> Array.toList
                |> List.indexedMap (check solved id)


radio : Bool -> Int -> Int -> Int -> Html Msg
radio solved row_id value column_id =
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


check : Bool -> Int -> Int -> Bool -> Html Msg
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


add_text : Inlines -> List (Html Msg) -> Html Msg
add_text inline toRow =
    inline
        |> List.map view_inf
        |> Html.td []
        |> List.singleton
        |> List.append toRow
        |> Html.tr []
