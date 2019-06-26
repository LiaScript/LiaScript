module Lia.Markdown.Quiz.SingleChoice.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.Inline.Types exposing (Annotation, Inlines, MultInlines)
import Lia.Markdown.Inline.View exposing (annotation, view_inf)
import Lia.Markdown.Quiz.SingleChoice.Types exposing (Quiz, State)
import Lia.Markdown.Quiz.SingleChoice.Update exposing (Msg(..))


view : Bool -> Quiz -> State -> Html Msg
view solved quiz state =
    quiz.options
        |> List.indexedMap (option solved state)
        |> Html.table [ Attr.attribute "cellspacing" "8" ]


option : Bool -> Int -> Int -> Inlines -> Html Msg
option solved checked id line =
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
