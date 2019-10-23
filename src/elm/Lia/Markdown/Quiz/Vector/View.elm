module Lia.Markdown.Quiz.Vector.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (view_inf)
import Lia.Markdown.Quiz.Vector.Types exposing (Quiz, State(..))
import Lia.Markdown.Quiz.Vector.Update exposing (Msg(..))
import Lia.Settings.Model exposing (Mode)


view : Mode -> Bool -> Quiz -> State -> Html Msg
view mode solved quiz state =
    case ( quiz.solution, state ) of
        ( SingleChoice _, SingleChoice list ) ->
            table (radio mode solved) quiz.options list

        ( MultipleChoice _, MultipleChoice list ) ->
            table (check mode solved) quiz.options list

        _ ->
            Html.text ""


table : (Bool -> ( Int, Inlines ) -> Html Msg) -> List Inlines -> List Bool -> Html Msg
table fn inlines bools =
    inlines
        |> List.indexedMap Tuple.pair
        |> List.map2 fn bools
        |> Html.table [ Attr.attribute "cellspacing" "8" ]


check : Mode -> Bool -> Bool -> ( Int, Inlines ) -> Html Msg
check mode solved checked ( id, line ) =
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
            |> List.map (view_inf mode)
            |> Html.td [ Attr.class "lia-label" ]
        ]


radio : Mode -> Bool -> Bool -> ( Int, Inlines ) -> Html Msg
radio mode solved checked ( id, line ) =
    Html.tr [ Attr.class "lia-radio-item" ]
        [ Html.td [ Attr.attribute "valign" "top", Attr.class "lia-label" ]
            [ Html.input
                [ Attr.type_ "radio"
                , Attr.checked checked
                , if solved then
                    Attr.disabled True

                  else
                    onClick (Toggle id)
                ]
                []
            , Html.span [ Attr.class "lia-radio-btn" ] []
            ]
        , line
            |> List.map (view_inf mode)
            |> Html.td [ Attr.class "lia-label" ]
        ]
