module Lia.Markdown.Quiz.View exposing (view, view_solution)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onBlur, onClick, onInput)
import Lia.Markdown.Inline.Types exposing (Annotation, Inlines, MultInlines)
import Lia.Markdown.Inline.View exposing (annotation, view_inf)
import Lia.Markdown.Quiz.Block.View as Block
import Lia.Markdown.Quiz.Model exposing (get_state)
import Lia.Markdown.Quiz.MultipleChoice.View as MultipleChoice
import Lia.Markdown.Quiz.SingleChoice.View as SingleChoice
import Lia.Markdown.Quiz.Types
    exposing
        ( Element
        , Quiz
        , Solution(..)
        , State(..)
        , Type(..)
        , Vector
        , initState
        )
import Lia.Markdown.Quiz.Update exposing (Msg(..))
import Translations exposing (Lang, quizCheck, quizChecked, quizResolved, quizSolution)


view : Lang -> Quiz -> Vector -> Html Msg
view lang quiz vector =
    case get_state vector quiz.id of
        Just elem ->
            elem.state
                |> state_view quiz.id quiz.quiz
                |> view_quiz lang elem quiz

        _ ->
            Html.text ""


state_view : Int -> Type -> State -> Html Msg
state_view id quiz state =
    case ( state, quiz ) of
        ( Block_State s, Block q ) ->
            s
                |> Block.view q
                |> Html.map (Block_Update id)

        ( SingleChoice_State s, SingleChoice q ) ->
            s
                |> SingleChoice.view q
                |> Html.map (SingleChoice_Update id)

        ( MultipleChoice_State s, MultipleChoice q ) ->
            s
                |> MultipleChoice.view q
                |> Html.map (MultipleChoice_Update id)

        _ ->
            Html.text ""


view_quiz : Lang -> Element -> Quiz -> Html Msg -> Html Msg
view_quiz lang state quiz fn =
    Html.p []
        [ if state.error_msg == "" then
            Html.text ""

          else
            Html.br [] []
        , if state.error_msg == "" then
            Html.text ""

          else
            Html.text state.error_msg
        , fn
        , view_button lang state.trial state.solved (Check quiz.id quiz.quiz quiz.javascript)
        , if quiz.quiz == Empty then
            Html.text ""

          else
            view_button_solution lang state.solved (ShowSolution quiz.id quiz.quiz)
        , view_hints quiz.id state.hint quiz.hints
        ]


view_button_solution : Lang -> Solution -> Msg -> Html Msg
view_button_solution lang solution msg =
    if solution == Open then
        Html.span
            [ Attr.class "lia-hint-btn"
            , onClick msg
            , Attr.title (quizSolution lang)
            , Attr.style "cursor" "pointer"
            ]
            [ Html.text "info" ]

    else
        Html.text ""


view_button : Lang -> Int -> Solution -> Msg -> Html Msg
view_button lang trials solved msg =
    case solved of
        Open ->
            if trials == 0 then
                Html.button [ Attr.class "lia-btn", onClick msg ] [ Html.text (quizCheck lang) ]

            else
                Html.button
                    [ Attr.class "lia-btn", Attr.class "lia-failure", onClick msg ]
                    [ Html.text (quizCheck lang ++ " " ++ String.fromInt trials) ]

        Solved ->
            Html.button
                [ Attr.class "lia-btn", Attr.class "lia-success", Attr.disabled True ]
                [ Html.text (quizChecked lang ++ " " ++ String.fromInt trials) ]

        ReSolved ->
            Html.button
                [ Attr.class "lia-btn", Attr.class "lia-warning", Attr.disabled True ]
                [ Html.text (quizResolved lang) ]


view_hints : Int -> Int -> MultInlines -> Html Msg
view_hints idx counter hints =
    let
        v_hints h c =
            case ( h, c ) of
                ( [], _ ) ->
                    []

                ( _, 0 ) ->
                    []

                ( x :: xs, _ ) ->
                    Html.p []
                        (Html.span [ Attr.class "lia-icon" ] [ Html.text "lightbulb_outline" ]
                            :: List.map view_inf x
                        )
                        :: v_hints xs (c - 1)
    in
    if counter < List.length hints then
        Html.span []
            [ Html.text " "
            , Html.span
                [ Attr.class "lia-hint-btn"
                , onClick (ShowHint idx)
                , Attr.title "show hint"
                , Attr.style "cursor" "pointer"
                ]
                [ Html.text "help" ]
            , Html.div
                [ Attr.class "lia-hints"
                ]
                (v_hints hints counter)
            ]

    else
        Html.div
            [ Attr.class "lia-hints"
            ]
            (v_hints hints counter)


view_solution : Vector -> Quiz -> ( Bool, Bool )
view_solution vector quiz =
    quiz.id
        |> get_state vector
        |> Maybe.map .solved
        |> Maybe.map (\s -> s /= Open)
        |> Maybe.withDefault False
        |> Tuple.pair (quiz.quiz == Empty)
