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
        , getClass
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
            viewState config elem quiz
                |> viewQuiz config elem quiz

        _ ->
            []


{-| Determine the quiz class based on the current state
-}
class : Int -> Vector -> String
class id vector =
    getState vector id
        |> Maybe.map (\s -> "lia-quiz-" ++ getClass s.state ++ getSolutionState s.solved)
        |> Maybe.withDefault ""
        |> (++) "lia-quiz "


getSolutionState : Solution -> String
getSolutionState s =
    case s of
        Solved ->
            " solved"

        ReSolved ->
            " resolved"

        _ ->
            " open"


{-| **private:** Simple router function that is used to match the current state
of a quiz with its type.
-}
viewState : Config sub -> Element -> Quiz -> List (Html (Msg sub))
viewState config elem quiz =
    let
        solved =
            case elem.solved of
                Solved ->
                    ( Just True, "is-success" )

                ReSolved ->
                    ( Just False, "is-disabled" )

                Open ->
                    ( Nothing
                    , if elem.trial == 0 then
                        ""

                      else
                        "is-failure"
                    )
    in
    case ( elem.state, quiz.quiz ) of
        ( Block_State s, Block_Type q ) ->
            s
                |> Block.view config solved q
                |> List.map (Html.map (Block_Update quiz.id))

        ( Vector_State s, Vector_Type q ) ->
            s
                |> Vector.view config (Tuple.mapFirst ((/=) Nothing) solved) q
                |> List.map (Html.map (Vector_Update quiz.id))

        ( Matrix_State s, Matrix_Type q ) ->
            [ s
                |> Matrix.view config (Tuple.mapFirst ((/=) Nothing) solved) q
                |> Html.map (Matrix_Update quiz.id)
            ]

        _ ->
            []


{-| **private:** Return the current quiz as List of elements that contains:

1.  maybe an error message (that originates from the external application of
    JavaScript)
2.  the body of the quiz itself, which might be of type `Block`, `Vector`, or
    `Matrix`
3.  the main check-button
4.  a button that reveals the solution 5 a hint section, that contains a hint
    button and a list of already revealed hints

-}
viewQuiz : Config sub -> Element -> Quiz -> List (Html (Msg sub)) -> List (Html (Msg sub))
viewQuiz config state quiz body =
    [ viewErrorMessage state.error_msg
    , Html.div [ Attr.class "lia-quiz__answers" ] body
    , Html.div [ Attr.class "lia-quiz__control" ]
        [ viewMainButton config state.trial state.solved (Check quiz.id quiz.quiz quiz.javascript)
        , viewSolutionButton config state.solved (ShowSolution quiz.id quiz.quiz)
        , viewHintButton quiz.id (Open == state.solved && state.hint < List.length quiz.hints)
        ]
    , viewFeedback state
    , viewHints config state.hint quiz.hints
    ]


viewFeedback : Element -> Html msg
viewFeedback state =
    case state.solved of
        Solved ->
            Html.div [ Attr.class "lia-quiz__feedback text-success" ] [ Html.text "Congratiulations this was the right answer" ]

        ReSolved ->
            Html.div [ Attr.class "lia-quiz__feedback text-disabled" ] [ Html.text "Resolved Anwser." ]

        Open ->
            if state.trial == 0 then
                Html.text ""

            else
                Html.div [ Attr.class "lia-quiz__feedback text-error" ] [ Html.text "That's not the right answer" ]


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
            [ Attr.class "lia-btn lia-btn--transparent lia-quiz__resolve"
            , onClick msg
            , quizSolution config.lang
                |> Attr.title
            ]
            [ Html.i [ Attr.class "lia-btn__icon icon icon-resolve" ] [] ]

    else
        Html.text ""


{-| **private:** Show the main check-button to compare the current state of the
quiz with the solution state. The number of trials is automatically added.
-}
viewMainButton : Config sub -> Int -> Solution -> Msg sub -> Html (Msg sub)
viewMainButton config trials solution msg =
    Html.button
        [ Attr.class "lia-btn lia-btn--outline lia-quiz__check"
        , onClick msg
        , Attr.disabled (solution /= Open)
        ]
        [ Html.text (quizCheck config.lang)
        , Html.text <|
            if trials > 0 then
                " " ++ String.fromInt trials

            else
                ""
        ]


{-| **private:** If hints have been added to the quiz by `[[?]]` these will
shown within a list and an additional button will be diplayed to reveal more
hints, if there are still hints not shown to the user and if the quiz has not
been solved yet.
-}
viewHints : Config sub -> Int -> MultInlines -> Html (Msg sub)
viewHints config counter hints =
    if List.isEmpty hints then
        Html.text ""

    else
        hints
            |> viewHintsWithCounter config counter
            |> Html.ul [ Attr.class "lia-list--unordered lia-quiz__hints" ]
            |> Html.map Script


{-| **private:** Show a generic hint button, every time it is clicked it will
reveal another hint from the list.
-}
viewHintButton : Int -> Bool -> Html (Msg sub)
viewHintButton id show =
    if show then
        Html.button
            [ Attr.class "lia-btn lia-btn--transparent lia-quiz__hint"
            , onClick (ShowHint id)
            , Attr.title "show hint"
            ]
            [ Html.i [ Attr.class "lia-btn__icon icon icon-hint" ] [] ]

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
