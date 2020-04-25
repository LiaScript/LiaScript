module Lia.Markdown.Quiz.Block.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Quiz.Block.Types exposing (Quiz, State(..))
import Lia.Markdown.Quiz.Block.Update exposing (Msg(..))
import Lia.Settings.Model exposing (Mode)


view : Config -> Bool -> Quiz -> State -> Html Msg
view config solved quiz state =
    case state of
        Text str ->
            text solved str

        Select open value ->
            value
                |> List.head
                |> Maybe.withDefault -1
                |> select config solved open quiz.options


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


select : Config -> Bool -> Bool -> List Inlines -> Int -> Html Msg
select config solved open options i =
    Html.span
        []
        [ Html.span
            [ Attr.class "lia-dropdown"
            , if solved then
                Attr.disabled True

              else
                onClick Toggle
            ]
            [ get_option config i options
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
            |> List.indexedMap (option config)
            |> Html.div
                [ Attr.class "lia-dropdown-options"
                , Attr.style "max-height" <|
                    if open then
                        "2000px"

                    else
                        "0px"
                ]
        ]


option : Config -> Int -> Inlines -> Html Msg
option config id opt =
    opt
        |> viewer config
        |> Html.div
            [ Attr.class "lia-dropdown-option"
            , id
                |> Choose
                |> onClick
            ]


get_option : Config -> Int -> List Inlines -> Html Msg
get_option config id list =
    case ( id, list ) of
        ( 0, x :: _ ) ->
            x
                |> viewer config
                |> Html.span []

        ( i, _ :: xs ) ->
            xs
                |> get_option config (i - 1)

        ( _, [] ) ->
            Html.text "choose"
