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
import List


view : Config sub -> Bool -> String -> Quiz -> State -> Html (Msg sub)
view config solved class quiz state =
    Html.div [ Attr.class "lia-table-responsive has-thead-sticky has-last-col-sticky" ]
        [ Html.table [ Attr.class "lia-table lia-survey-matrix is-alternating" ]
            [ header config quiz.headers
            , state
                |> Array.toList
                |> List.indexedMap (tr solved class)
                |> List.map2 (add_text config) quiz.options
                |> Html.tbody [ Attr.class "lia-table__body lia-survey-matrix__body" ]
            ]
        ]


header : Config sub -> List Inlines -> Html (Msg sub)
header config inlines =
    List.append (List.map (th config) inlines) [ Html.th [ Attr.class "lia-table__header lia-survey-matrix__header" ] [] ]
        |> Html.thead [ Attr.class "lia-table__head lia-survey-matrix__head" ]


th : Config sub -> Inlines -> Html (Msg sub)
th config =
    viewer config
        >> Html.th [ Attr.class "lia-table__header lia-survey-matrix__header" ]
        >> Html.map Script


tr : Bool -> String -> Int -> Vector.State -> List (Html (Msg sub))
tr solved class id state =
    case state of
        Vector.SingleChoice list ->
            list |> List.indexedMap (radio solved class id)

        Vector.MultipleChoice list ->
            list |> List.indexedMap (check solved class id)


radio : Bool -> String -> Int -> Int -> Bool -> Html (Msg sub)
radio solved colorClass row_id column_id value =
    Html.td [ Attr.class "lia-table__data lia-survey-matrix__data" ]
        [ Html.input
            [ Attr.class "lia-radio"
            , Attr.class colorClass
            , Attr.type_ "radio"
            , Attr.checked value
            , if solved then
                Attr.disabled True

              else
                onClick <| Toggle row_id column_id
            ]
            []
        ]


check : Bool -> String -> Int -> Int -> Bool -> Html (Msg sub)
check solved colorClass row_id column_id value =
    Html.td [ Attr.class "lia-table__data lia-survey-matrix__data" ]
        [ Html.input
            [ Attr.class "lia-checkbox"
            , Attr.class colorClass
            , Attr.type_ "checkbox"
            , Attr.checked value
            , if solved then
                Attr.disabled True

              else
                onClick <| Toggle row_id column_id
            ]
            []
        ]


add_text : Config sub -> Inlines -> List (Html (Msg sub)) -> Html (Msg sub)
add_text config inline toRow =
    inline
        |> viewer config
        |> Html.td [ Attr.class "lia-table__data lia-survey-matrix__data" ]
        |> Html.map Script
        |> List.singleton
        |> List.append toRow
        |> Html.tr [ Attr.class "lia-table__row lia-survey-matrix__row" ]
