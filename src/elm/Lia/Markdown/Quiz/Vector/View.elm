module Lia.Markdown.Quiz.Vector.View exposing (view)

import Array
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (view_inf)
import Lia.Markdown.Quiz.Vector.Types exposing (Quiz, State(..))
import Lia.Markdown.Quiz.Vector.Update exposing (Msg(..))


view : Bool -> Quiz -> State -> Html Msg
view solved quiz state =
    case ( quiz.solution, state ) of
        ( SingleChoice _ q, SingleChoice _ s ) ->
            quiz.options
                |> List.indexedMap
                    (s
                        |> List.head
                        |> Maybe.withDefault -1
                        |> radio solved
                    )
                |> Html.table [ Attr.attribute "cellspacing" "8" ]

        ( MultipleChoice q, MultipleChoice s ) ->
            let
                list =
                    Array.toList s
            in
            quiz.options
                |> List.indexedMap Tuple.pair
                |> List.map2 (check solved) list
                |> Html.table [ Attr.attribute "cellspacing" "8" ]

        _ ->
            Html.text ""


check : Bool -> Bool -> ( Int, Inlines ) -> Html Msg
check solved checked ( id, line ) =
    Html.tr [ Attr.class "lia-check-item" ]
        [ Html.td
            [ Attr.attribute "valign" "top", Attr.class "lia-label" ]
            [ Html.input
                [ Attr.type_ "checkbox"
                , Attr.checked checked
                , if solved then
                    Attr.disabled True

                  else
                    onClick (Toggle id)
                ]
                []
            , Html.span
                [ Attr.class "lia-check-btn" ]
                [ Html.text "check" ]
            ]
        , line
            |> List.map view_inf
            |> Html.td [ Attr.class "lia-label" ]
        ]


radio : Bool -> Int -> Int -> Inlines -> Html Msg
radio solved checked id line =
    Html.tr [ Attr.class "lia-radio-item" ]
        [ Html.td [ Attr.attribute "valign" "top", Attr.class "lia-label" ]
            [ Html.input
                [ Attr.type_ "radio"
                , Attr.checked (id == checked)
                , if solved then
                    Attr.disabled True

                  else
                    onClick (Toggle id)
                ]
                []
            , Html.span [ Attr.class "lia-radio-btn" ] []
            ]
        , line
            |> List.map view_inf
            |> Html.td [ Attr.class "lia-label" ]
        ]
