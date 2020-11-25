module Lia.Markdown.Quiz.Vector.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Quiz.Vector.Types exposing (Quiz, State(..))
import Lia.Markdown.Quiz.Vector.Update exposing (Msg(..))


view : Config sub -> Bool -> Quiz -> State -> Html (Msg sub)
view config solved quiz state =
    case ( quiz.solution, state ) of
        ( SingleChoice _, SingleChoice list ) ->
            table (radio config solved) quiz.options list

        ( MultipleChoice _, MultipleChoice list ) ->
            table (check config solved) quiz.options list

        _ ->
            Html.text ""


table : (Bool -> ( Int, Inlines ) -> Html (Msg sub)) -> List Inlines -> List Bool -> Html (Msg sub)
table fn inlines bools =
    inlines
        |> List.indexedMap Tuple.pair
        |> List.map2 fn bools
        |> Html.table [ Attr.attribute "cellspacing" "8" ]


check : Config sub -> Bool -> Bool -> ( Int, Inlines ) -> Html (Msg sub)
check config solved checked ( id, line ) =
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
            |> viewer config
            |> Html.td [ Attr.class "lia-label" ]
            |> Html.map Script
        ]


radio : Config sub -> Bool -> Bool -> ( Int, Inlines ) -> Html (Msg sub)
radio config solved checked ( id, line ) =
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
            |> viewer config
            |> Html.td [ Attr.class "lia-label" ]
            |> Html.map Script
        ]
