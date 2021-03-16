module Lia.Markdown.Quiz.Block.View exposing (view)

import Accessibility.Widget as A11y_Widget
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Quiz.Block.Types exposing (Quiz, State(..))
import Lia.Markdown.Quiz.Block.Update exposing (Msg(..))
import Lia.Utils exposing (blockKeydown)


view : Config sub -> ( Maybe Bool, String ) -> Quiz -> State -> List (Html (Msg sub))
view config ( solved, colorClass ) quiz state =
    case state of
        Text str ->
            [ text solved colorClass str
            , case solved of
                Nothing ->
                    Html.text ""

                Just success ->
                    Html.i
                        [ Attr.class "icon"
                        , Attr.class <|
                            if success then
                                "icon-check text-success"

                            else
                                "icon-check text-success"
                        , Attr.style "position" "absolute"
                        , Attr.style "top" "1rem"
                        , Attr.style "right" "1rem"
                        , A11y_Widget.hidden True
                        ]
                        []
            ]

        Select open value ->
            [ value
                |> List.head
                |> Maybe.withDefault -1
                |> select config (solved /= Nothing) colorClass open quiz.options
            ]


text : Maybe Bool -> String -> String -> Html (Msg sub)
text solved colorClass state =
    Html.input
        [ Attr.type_ "input"
        , Attr.class "lia-input lia-quiz__input"
        , Attr.class <|
            if solved /= Nothing then
                "lia-input--disabled"

            else
                ""
        , Attr.class colorClass
        , Attr.value state
        , Attr.disabled (solved /= Nothing)
        , onInput Input
        , blockKeydown (Input state)
        ]
        []


select : Config sub -> Bool -> String -> Bool -> List Inlines -> Int -> Html (Msg sub)
select config solved colorClass open options i =
    Html.span
        [ Attr.class colorClass ]
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


option : Config sub -> Int -> Inlines -> Html (Msg sub)
option config id =
    viewer config
        >> Html.div []
        >> Html.map Script
        >> List.singleton
        >> Html.div
            [ Attr.class "lia-dropdown-option"
            , id
                |> Choose
                |> onClick
            ]


get_option : Config sub -> Int -> List Inlines -> Html (Msg sub)
get_option config id list =
    case ( id, list ) of
        ( 0, x :: _ ) ->
            x
                |> viewer config
                |> Html.span []
                |> Html.map Script

        ( i, _ :: xs ) ->
            xs
                |> get_option config (i - 1)

        ( _, [] ) ->
            Html.text "choose"
