module Lia.Markdown.Quiz.Block.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (view_inf)
import Lia.Markdown.Quiz.Block.Types exposing (Quiz, State(..))
import Lia.Markdown.Quiz.Block.Update exposing (Msg(..))


view : Bool -> Quiz -> State -> Html Msg
view solved quiz state =
    case state of
        Text str ->
            text solved str

        Select open i ->
            select solved open i quiz.options


text : Bool -> String -> Html Msg
text solved state =
    Html.input
        [ Attr.type_ "input"
        , Attr.class "lia-input"
        , Attr.value state
        , Attr.disabled solved
        , onInput Input
        ]
        []


select : Bool -> Bool -> Int -> List Inlines -> Html Msg
select solved open i options =
    Html.span
        []
        [ Html.span
            [ Attr.class "lia-dropdown"
            , if solved then
                Attr.disabled True

              else
                onClick Toggle
            ]
            [ get_option i options
            , Html.span
                [ Attr.class "lia-icon"
                , Attr.style "float" "right"
                ]
                [ if open then
                    Html.text "arrow_drop_down"

                  else
                    Html.text "arrow_drop_up"
                ]
            ]
        , options
            |> List.indexedMap option
            |> Html.div
                [ Attr.class "lia-dropdown-options"
                , Attr.style "max-height" <|
                    if open then
                        "2000px"

                    else
                        "0px"
                ]
        ]


option : Int -> Inlines -> Html Msg
option id opt =
    opt
        |> List.map view_inf
        |> Html.div
            [ Attr.class "lia-dropdown-option"
            , id
                |> Choose
                |> onClick
            ]


get_option : Int -> List Inlines -> Html Msg
get_option id list =
    case ( id, list ) of
        ( 0, x :: xs ) ->
            x |> List.map view_inf |> Html.span []

        ( i, x :: xs ) ->
            get_option (i - 1) xs

        ( i, [] ) ->
            Html.text "choose"
