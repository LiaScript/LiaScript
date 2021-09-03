module Lia.Markdown.Quiz.Block.View exposing (view)

import Accessibility.Role as A11y_Role
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
import Translations


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
        , A11y_Widget.label "quiz answer"
        ]
        []


select : Config sub -> Solution.State -> Bool -> List Inlines -> Int -> Html (Msg sub)
select config solution open options i =
    Html.div
        [ Attr.class "lia-dropdown"
        , Attr.class <| Solution.toClass solution
        , if Solution.isOpen solution then
            onClick Toggle

          else
            Attr.disabled True
        ]
        [ Html.span
            [ Attr.class "lia-dropdown__selected"
            , A11y_Widget.hidden False
            , A11y_Role.button
            , A11y_Widget.expanded open
            ]
            [ get_option config i options
            , Html.i
                [ Attr.class <|
                    "icon"
                        ++ (if open then
                                " icon-chevron-up"

                            else
                                " icon-chevron-down"
                           )
                , A11y_Role.button
                ]
                []
            ]
        , options
            |> List.indexedMap (option config)
            |> Html.div
                [ Attr.class "lia-dropdown__options"
                , Attr.class <|
                    if open then
                        "is-visible"

                    else
                        "is-hidden"
                ]
        ]


option : Config sub -> Int -> Inlines -> Html (Msg sub)
option config id =
    viewer config
        >> Html.div []
        >> Html.map Script
        >> List.singleton
        >> Html.div
            [ Attr.class "lia-dropdown__option"
            , id
                |> Choose
                |> onClick
            , A11y_Role.listItem
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
            get_option config (i - 1) xs

        ( _, [] ) ->
            Html.span [] [ Html.text <| Translations.quizSelection config.lang ]
