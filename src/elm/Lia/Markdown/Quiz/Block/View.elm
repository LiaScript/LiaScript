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
import Lia.Markdown.Quiz.Solution as Solution
import Lia.Utils exposing (blockKeydown, icon)


view : Config sub -> Solution.State -> Quiz -> State -> List (Html (Msg sub))
view config solution quiz state =
    case state of
        Text str ->
            [ text solution str
            , case solution of
                ( Solution.Solved, _ ) ->
                    icon "icon-check text-success"
                        [ Attr.style "position" "absolute"
                        , Attr.style "top" "1rem"
                        , Attr.style "right" "1rem"
                        ]

                ( Solution.Open, trials ) ->
                    if trials > 0 then
                        icon "icon-close text-error"
                            [ Attr.style "position" "absolute"
                            , Attr.style "top" "1rem"
                            , Attr.style "right" "1rem"
                            ]

                    else
                        Html.text ""

                _ ->
                    Html.text ""
            ]

        Select open value ->
            [ value
                |> List.head
                |> Maybe.withDefault -1
                |> select config solution open quiz.options
            ]


text : Solution.State -> String -> Html (Msg sub)
text solution state =
    Html.input
        [ Attr.type_ "input"
        , Attr.class "lia-input lia-quiz__input"
        , Attr.class <|
            if Solution.isOpen solution then
                ""

            else
                "lia-input--disabled"
        , Attr.class (Solution.toClass solution)
        , Attr.value state
        , Attr.disabled (not <| Solution.isOpen solution)
        , onInput Input
        , blockKeydown (Input state)
        ]
        []


select : Config sub -> Solution.State -> Bool -> List Inlines -> Int -> Html (Msg sub)
select config solution open options i =
    Html.span
        [ Attr.class <| Solution.toClass solution ]
        [ Html.span
            [ Attr.class "lia-dropdown"
            , if Solution.isOpen solution then
                onClick Toggle

              else
                Attr.disabled True
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
