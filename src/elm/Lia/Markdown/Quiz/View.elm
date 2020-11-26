module Lia.Markdown.Quiz.View exposing (class, view, view_solution)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (MultInlines)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Quiz.Block.View as Block
import Lia.Markdown.Quiz.Matrix.View as Matrix
import Lia.Markdown.Quiz.Types
    exposing
        ( Element
        , Quiz
        , Solution(..)
        , State(..)
        , Type(..)
        , Vector
        , getState
        , solved
        )
import Lia.Markdown.Quiz.Update exposing (Msg(..))
import Lia.Markdown.Quiz.Vector.View as Vector
import Translations exposing (quizCheck, quizChecked, quizResolved, quizSolution)


view : Config sub -> Quiz -> Vector -> Html (Msg sub)
view config quiz vector =
    case getState vector quiz.id of
        Just elem ->
            state_view config (solved elem) elem.state quiz
                |> view_quiz config elem quiz

        _ ->
            Html.text ""


class : Int -> Vector -> String
class id vector =
    case
        getState vector id
            |> Maybe.map .solved
    of
        Just Solved ->
            "lia-quiz lia-card solved"

        Just ReSolved ->
            "lia-quiz lia-card resolved"

        _ ->
            "lia-quiz lia-card open"


state_view : Config sub -> Bool -> State -> Quiz -> Html (Msg sub)
state_view config solved state quiz =
    case ( state, quiz.quiz ) of
        ( Block_State s, Block_Type q ) ->
            s
                |> Block.view config solved q
                |> Html.map (Block_Update quiz.id)

        ( Vector_State s, Vector_Type q ) ->
            s
                |> Vector.view config solved q
                |> Html.map (Vector_Update quiz.id)

        ( Matrix_State s, Matrix_Type q ) ->
            s
                |> Matrix.view config solved q
                |> Html.map (Matrix_Update quiz.id)

        _ ->
            Html.text ""


view_quiz : Config sub -> Element -> Quiz -> Html (Msg sub) -> Html (Msg sub)
view_quiz config state quiz fn =
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
        , view_button config state.trial state.solved (Check quiz.id quiz.quiz quiz.javascript)
        , view_button_solution config state.solved (ShowSolution quiz.id quiz.quiz)
        , view_hints config quiz.id state.hint quiz.hints
        ]


view_button_solution : Config sub -> Solution -> Msg sub -> Html (Msg sub)
view_button_solution config solution msg =
    if solution == Open then
        Html.span
            [ Attr.class "lia-hint-btn"
            , onClick msg
            , Attr.title (quizSolution config.lang)
            , Attr.style "cursor" "pointer"
            ]
            [ Html.text "info" ]

    else
        Html.text ""


view_button : Config sub -> Int -> Solution -> Msg sub -> Html (Msg sub)
view_button config trials solved msg =
    case solved of
        Open ->
            if trials == 0 then
                Html.button
                    [ Attr.class "lia-btn", onClick msg ]
                    [ Html.text (quizCheck config.lang) ]

            else
                Html.button
                    [ Attr.class "lia-btn", Attr.class "lia-failure", onClick msg ]
                    [ Html.text (quizCheck config.lang ++ " " ++ String.fromInt trials) ]

        Solved ->
            Html.button
                [ Attr.class "lia-btn", Attr.class "lia-success", Attr.disabled True ]
                [ Html.text (quizChecked config.lang ++ " " ++ String.fromInt trials) ]

        ReSolved ->
            Html.button
                [ Attr.class "lia-btn", Attr.class "lia-warning", Attr.disabled True ]
                [ Html.text (quizResolved config.lang) ]


view_hints : Config sub -> Int -> Int -> MultInlines -> Html (Msg sub)
view_hints config idx counter hints =
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
                            :: viewer config x
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
            , v_hints hints counter
                |> Html.div [ Attr.class "lia-hints" ]
                |> Html.map Script
            ]

    else
        v_hints hints counter
            |> Html.div [ Attr.class "lia-hints" ]
            |> Html.map Script


view_solution : Vector -> Quiz -> Bool
view_solution vector quiz =
    quiz.id
        |> getState vector
        |> Maybe.map solved
        |> Maybe.withDefault False
