module Lia.Markdown.Quiz.View exposing (class, showSolution, view)

{-| This module defines the basic frame for all subsequent and specialized
quizzes. It adds a common checkButton, hintButton, and resolveButton and shows
hints.

TODO:

  - Add translations for web accessability also:
    1.  check: check the solution of the current quiz
    2.  reveal: reveal the solution of the quiz
    3.  show hint: show an hint
    4.  state:
          - open: the quiz has not been touched yet
          - resolved: resolved quiz
          - solved: soved quiz

-}

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
        , isSolved
        )
import Lia.Markdown.Quiz.Update exposing (Msg(..))
import Lia.Markdown.Quiz.Vector.View as Vector
import Translations exposing (quizCheck, quizChecked, quizResolved, quizSolution)


{-| Main Quiz view function.
-}
view : Config sub -> Quiz -> Vector -> List (Html (Msg sub))
view config quiz vector =
    case getState vector quiz.id of
        Just elem ->
            viewState config (isSolved elem) elem.state quiz
                |> viewQuiz config elem quiz

        _ ->
            []


{-| Determine the quiz class based on the current state
-}
class : Int -> Vector -> String
class id vector =
    case
        getState vector id
            |> Maybe.map .solved
    of
        Just Solved ->
            "lia-quiz solved"

        Just ReSolved ->
            "lia-quiz resolved"

        _ ->
            "lia-quiz open"


{-| **private:** Simple router function that is used to match the current state
of a quiz with its type.
-}
viewState : Config sub -> Bool -> State -> Quiz -> Html (Msg sub)
viewState config solved state quiz =
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


{-| **private:** Return the current quiz as List of elements that contains:

1.  maybe an error message (that originates from the external application of
    JavaScript)
2.  the body of the quiz itself, which might be of type `Block`, `Vector`, or
    `Matrix`
3.  the main check-button
4.  a button that reveals the solution 5 a hint section, that contains a hint
    button and a list of already revealed hints

-}
viewQuiz : Config sub -> Element -> Quiz -> Html (Msg sub) -> List (Html (Msg sub))
viewQuiz config state quiz body =
    List.append
        [ viewErrorMessage state.error_msg
        , body
        , viewMainButton config state.trial state.solved (Check quiz.id quiz.quiz quiz.javascript)
        , viewSolutionButton config state.solved (ShowSolution quiz.id quiz.quiz)
        ]
        (viewHints config state.solved quiz.id state.hint quiz.hints)


{-| **private:** Show an error-message, which results from the execution of an
associated script-tag.

TODO: needs to be styled appropriately

-}
viewErrorMessage : String -> Html msg
viewErrorMessage str =
    if str == "" then
        Html.text ""

    else
        -- TODO: mark as error
        Html.div [] [ Html.text str ]


{-| **private:** Show the solution button only if the quiz has not been solved
yet.
-}
viewSolutionButton : Config sub -> Solution -> Msg sub -> Html (Msg sub)
viewSolutionButton config solution msg =
    if solution == Open then
        Html.button
            [ Attr.class "lia-btn lia-btn--hint"
            , onClick msg
            , quizSolution config.lang
                |> Attr.title
            ]
            [ Html.text "info" ]

    else
        Html.text ""


{-| **private:** Show the main check-button to compare the current state of the
quiz with the solution state. The number of trials is automatically added.
-}
viewMainButton : Config sub -> Int -> Solution -> Msg sub -> Html (Msg sub)
viewMainButton config trials solution msg =
    case solution of
        Open ->
            if trials == 0 then
                Html.button
                    [ Attr.class "lia-btn", onClick msg ]
                    [ Html.text (quizCheck config.lang) ]

            else
                Html.button
                    [ Attr.class "lia-btn lia-failure", onClick msg ]
                    [ Html.text (quizCheck config.lang ++ " " ++ String.fromInt trials) ]

        Solved ->
            Html.button
                [ Attr.class "lia-btn lia-success", Attr.disabled True ]
                [ Html.text (quizChecked config.lang ++ " " ++ String.fromInt trials) ]

        ReSolved ->
            Html.button
                [ Attr.class "lia-btn lia-warning", Attr.disabled True ]
                [ Html.text (quizResolved config.lang) ]


{-| **private:** If hints have been added to the quiz by `[[?]]` these will
shown within a list and an additional button will be diplayed to reveal more
hints, if there are still hints not shown to the user and if the quiz has not
been solved yet.
-}
viewHints : Config sub -> Solution -> Int -> Int -> MultInlines -> List (Html (Msg sub))
viewHints config solution id counter hints =
    if List.isEmpty hints then
        []

    else
        [ viewHintButton id (Open == solution && counter < List.length hints)
        , hints
            |> viewHintsWithCounter config counter
            |> Html.ul [ Attr.class "lia-hints" ]
            |> Html.map Script
        ]


{-| **private:** Show a generic hint button, every time it is clicked it will
reveal another hint from the list.
-}
viewHintButton : Int -> Bool -> Html (Msg sub)
viewHintButton id show =
    if show then
        Html.button
            [ Attr.class "lia-btn lia-btn--hint"
            , onClick (ShowHint id)
            , Attr.title "show hint"
            ]
            [ Html.text "help" ]

    else
        Html.text ""


{-| **private: ** Show all hints within the list based on the passed counter
value.
-}
viewHintsWithCounter config counter hints =
    case ( hints, counter ) of
        ( [], _ ) ->
            []

        ( _, 0 ) ->
            []

        ( x :: xs, _ ) ->
            Html.li [] (viewer config x)
                :: viewHintsWithCounter config (counter - 1) xs


{-| Check the state of quiz:

    Open -> False

    Solved -> True

    Resolved -> True

-}
showSolution : Vector -> Quiz -> Bool
showSolution vector quiz =
    quiz.id
        |> getState vector
        |> Maybe.map isSolved
        |> Maybe.withDefault False
