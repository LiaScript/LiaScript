module Lia.Markdown.Quiz.Matrix.View exposing (view)

import Array
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (view_inf)
import Lia.Markdown.Quiz.Matrix.Types exposing (Quiz, State)
import Lia.Markdown.Quiz.Matrix.Update exposing (Msg(..))
import Lia.Markdown.Quiz.Vector.Types as Vector
import Lia.Settings.Model exposing (Mode)


view : Mode -> Bool -> Quiz -> State -> Html Msg
view mode solved quiz state =
    state
        |> Array.toList
        |> List.indexedMap (tr solved)
        |> List.map2 (add_text mode) quiz.options
        |> (::) (header mode quiz.headers)
        |> Html.table [ Attr.class "lia-survey-matrix" ]


header : Mode -> List Inlines -> Html Msg
header mode inlines =
    inlines
        |> List.map (th mode)
        |> Html.tr [ Attr.class "lia-label" ]


th : Mode -> Inlines -> Html Msg
th mode inlines =
    inlines
        |> List.map (view_inf mode)
        |> Html.th [ Attr.align "center" ]


tr : Bool -> Int -> Vector.State -> List (Html Msg)
tr solved id state =
    case state of
        Vector.SingleChoice list ->
            list |> List.indexedMap (radio solved id)

        Vector.MultipleChoice list ->
            list |> List.indexedMap (check solved id)


radio : Bool -> Int -> Int -> Bool -> Html Msg
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


add_text : Mode -> Inlines -> List (Html Msg) -> Html Msg
add_text mode inline toRow =
    inline
        |> List.map (view_inf mode)
        |> Html.td []
        |> List.singleton
        |> List.append toRow
        |> Html.tr []
