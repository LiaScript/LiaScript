module Lia.Markdown.Quiz.Block.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (view_inf)
import Lia.Markdown.Quiz.Block.Types exposing (Quiz, State(..))
import Lia.Markdown.Quiz.Block.Update exposing (Msg(..))
import Lia.Settings.Model exposing (Mode)


view : Mode -> Bool -> Quiz -> State -> Html Msg
view mode solved quiz state =
    case state of
        Text str ->
            text solved str

        Select open value ->
            value
                |> List.head
                |> Maybe.withDefault -1
                |> select mode solved open quiz.options


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


select : Mode -> Bool -> Bool -> List Inlines -> Int -> Html Msg
select mode solved open options i =
    Html.span
        []
        [ Html.span
            [ Attr.class "lia-dropdown"
            , if solved then
                Attr.disabled True

              else
                onClick Toggle
            ]
            [ get_option mode i options
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
            |> List.indexedMap (option mode)
            |> Html.div
                [ Attr.class "lia-dropdown-options"
                , Attr.style "max-height" <|
                    if open then
                        "2000px"

                    else
                        "0px"
                ]
        ]


option : Mode -> Int -> Inlines -> Html Msg
option mode id opt =
    opt
        |> List.map (view_inf mode)
        |> Html.div
            [ Attr.class "lia-dropdown-option"
            , id
                |> Choose
                |> onClick
            ]


get_option : Mode -> Int -> List Inlines -> Html Msg
get_option mode id list =
    case ( id, list ) of
        ( 0, x :: _ ) ->
            x
                |> List.map (view_inf mode)
                |> Html.span []

        ( i, _ :: xs ) ->
            xs
                |> get_option mode (i - 1)

        ( _, [] ) ->
            Html.text "choose"
