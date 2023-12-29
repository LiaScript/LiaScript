module Lia.Markdown.Quiz.View exposing
    ( class
    , maybeConfig
    , showSolution
    , syncAttributes
    , view
    )

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
          - solved: solved quiz

-}

import Accessibility.Aria as A11y_Aria
import Accessibility.Role as A11y_Role
import Accessibility.Widget as A11y_Widget
import Array
import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Json.Encode as JE
import Lia.Markdown.Chart.View as Chart
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Quiz.Block.View as Block
import Lia.Markdown.Quiz.Matrix.View as Matrix
import Lia.Markdown.Quiz.Multi.View as Multi
import Lia.Markdown.Quiz.Solution as Solution exposing (Solution)
import Lia.Markdown.Quiz.Sync exposing (Sync)
import Lia.Markdown.Quiz.Types
    exposing
        ( Element
        , Quiz
        , State(..)
        , Type(..)
        , Vector
        , getClass
        , isSolved
        )
import Lia.Markdown.Quiz.Update exposing (Msg(..))
import Lia.Markdown.Quiz.Vector.View as Vector
import Lia.Markdown.Types as Markdown
import Lia.Sync.Types as Sync
import Lia.Utils exposing (btn, btnIcon, percentage)
import List.Extra
import Translations
    exposing
        ( Lang
        , quizAnswerError
        , quizAnswerResolved
        , quizAnswerSuccess
        , quizCheck
        , quizLabelCheck
        , quizLabelSolution
        , quizSolution
        )


syncAttributes : List ( String, String )
syncAttributes =
    [ ( "style", "height: 150px; width: 100%" ), ( "class", "lia-quiz__sync" ) ]


{-| Main Quiz view function.
-}
view : Config sub -> Maybe String -> Quiz Markdown.Block -> Vector -> ( Maybe Int, List (Html (Msg sub)) )
view config labeledBy quiz vector =
    case Array.get quiz.id vector of
        Just elem ->
            ( elem.scriptID
            , viewState config elem quiz
                |> viewQuiz config labeledBy elem quiz
                |> viewSync config (Sync.get config.sync .quiz config.slide quiz.id)
            )

        _ ->
            ( Nothing, [] )


maybeConfig : Config sub -> Quiz Markdown.Block -> Vector -> Maybe ( Config sub, Markdown.Block )
maybeConfig config quiz vector =
    case ( Array.get quiz.id vector, quiz.quiz ) of
        ( Just elem, Multi_Type q ) ->
            case elem.state of
                Multi_State state ->
                    case
                        Multi.view
                            { config = config
                            , id = quiz.id
                            , active = elem.solved == Solution.Open
                            , partiallyCorrect = elem.partiallySolved
                            , quiz = q
                            , state = state
                            }
                    of
                        ( newConfig, Just block ) ->
                            Just ( newConfig, block )

                        _ ->
                            Nothing

                _ ->
                    Nothing

        _ ->
            Nothing


viewSync : Config sub -> Maybe (List Sync) -> List (Html msg) -> List (Html msg)
viewSync config syncData quiz =
    case ( syncData, syncData |> Maybe.map List.length ) of
        ( Just _, Just 0 ) ->
            quiz

        ( Just data, Just length ) ->
            let
                total =
                    toFloat length

                chartData =
                    data
                        |> List.Extra.gatherEquals
                        |> List.map
                            (\( i, list ) ->
                                let
                                    absolute =
                                        1 + List.length list

                                    relative =
                                        percentage total absolute
                                in
                                case i of
                                    Just i_ ->
                                        ( JE.string ("Trial " ++ String.fromInt i_)
                                        , JE.object
                                            [ ( "value", JE.float relative )
                                            , ( "label"
                                              , JE.object
                                                    [ ( "show", JE.bool True )
                                                    , ( "formatter"
                                                      , String.fromInt absolute
                                                            ++ " ("
                                                            ++ String.fromFloat relative
                                                            ++ "%)"
                                                            |> JE.string
                                                      )
                                                    ]
                                              )
                                            ]
                                        )

                                    Nothing ->
                                        ( JE.string "Resolved"
                                        , JE.object
                                            [ ( "value"
                                              , JE.float relative
                                              )
                                            , ( "itemStyle"
                                              , JE.object [ ( "color", JE.string "#888" ) ]
                                              )
                                            , ( "label"
                                              , JE.object
                                                    [ ( "show", JE.bool True )
                                                    , ( "formatter"
                                                      , String.fromInt absolute
                                                            ++ " ("
                                                            ++ String.fromFloat relative
                                                            ++ "%)"
                                                            |> JE.string
                                                      )
                                                    ]
                                              )
                                            ]
                                        )
                            )
            in
            JE.object
                [ ( "grid"
                  , JE.object
                        [ ( "left", JE.int 10 )
                        , ( "top", JE.int 20 )
                        , ( "bottom", JE.int 20 )
                        , ( "right", JE.int 10 )
                        ]
                  )
                , ( "xAxis"
                  , JE.object
                        [ ( "type", JE.string "category" )
                        , ( "data"
                          , JE.list Tuple.first chartData
                          )
                        ]
                  )
                , ( "yAxis"
                  , JE.object
                        [ ( "type", JE.string "value" )
                        , ( "show", JE.bool False )
                        ]
                  )
                , ( "series"
                  , [ [ ( "type", JE.string "bar" )
                      , ( "data"
                        , JE.list Tuple.second chartData
                        )
                      ]
                    ]
                        |> JE.list JE.object
                  )
                ]
                |> Chart.eCharts
                    { lang = config.lang
                    , attr = syncAttributes
                    , light = config.light
                    }
                    Nothing
                |> List.singleton
                |> List.append quiz

        _ ->
            quiz


{-| Determine the quiz class based on the current state
-}
class : Int -> Vector -> String
class id =
    Array.get id
        >> Maybe.map (\s -> "lia-quiz-" ++ getClass s.state ++ " " ++ Solution.toString s.solved)
        >> Maybe.withDefault ""
        >> (++) "lia-quiz "


{-| **private:** Simple router function that is used to match the current state
of a quiz with its type.
-}
viewState :
    Config sub
    -> Element
    -> Quiz x
    -> ( List (Attribute (Msg sub)), List (Html (Msg sub)) )
viewState config elem quiz =
    case ( elem.state, quiz.quiz ) of
        ( Block_State s, Block_Type q ) ->
            ( []
            , s
                |> Block.view config ( elem.solved, elem.trial ) q
                |> List.map (Html.map (Block_Update quiz.id))
            )

        ( Vector_State s, Vector_Type q ) ->
            s
                |> Vector.view config
                    (elem.solved == Solution.Open)
                    (Solution.toClass ( elem.solved, elem.trial ))
                    q
                |> Tuple.mapSecond
                    (shuffle elem.opt.randomize
                        >> List.map (Html.map (Vector_Update quiz.id))
                    )

        ( Matrix_State s, Matrix_Type q ) ->
            ( []
            , [ { config = config
                , shuffle = shuffle elem.opt.randomize
                , open = elem.solved == Solution.Open
                , class = Solution.toClass ( elem.solved, elem.trial )
                , quiz = q
                , state = s
                , partiallySolved = elem.partiallySolved
                }
                    |> Matrix.view
                    |> Html.map (Matrix_Update quiz.id)
              ]
            )

        _ ->
            ( [], [] )


shuffle : Maybe (List Int) -> List x -> List x
shuffle randomize rows =
    case randomize of
        Nothing ->
            rows

        Just order ->
            rows
                |> List.map2 Tuple.pair order
                |> List.sortBy Tuple.first
                |> List.map Tuple.second


{-| **private:** Return the current quiz as List of elements that contains:

1.  maybe an error message (that originates from the external application of
    JavaScript)
2.  the body of the quiz itself, which might be of type `Block`, `Vector`, or
    `Matrix`
3.  the main check-button
4.  a button that reveals the solution 5 a hint section, that contains a hint
    button and a list of already revealed hints

-}
viewQuiz :
    Config sub
    -> Maybe String
    -> Element
    -> Quiz Markdown.Block
    -> ( List (Attribute (Msg sub)), List (Html (Msg sub)) )
    -> List (Html (Msg sub))
viewQuiz config labeledBy state quiz ( attr, body ) =
    [ Html.div
        (Attr.class "lia-quiz__answers"
            :: (labeledBy
                    |> Maybe.map A11y_Aria.labelledBy
                    |> Maybe.withDefault (Attr.class "")
               )
            :: attr
        )
        body
    , Html.div [ Attr.class "lia-quiz__control" ]
        [ viewMainButton config state.trial state.solved (Check quiz.id quiz.quiz)
        , viewSolutionButton
            { config = config
            , solution = state.solved
            , msg = ShowSolution quiz.id quiz.quiz
            , hidden = state.trial < state.opt.showResolveAt
            }
        , viewHintButton
            { id = quiz.id
            , show = (quiz.hints /= []) && (state.trial >= state.opt.showHintsAt)
            , active = Solution.Open == state.solved && state.hint < List.length quiz.hints
            , title = Translations.quizHint config.lang
            }
        ]
    , viewFeedback config.lang state
    , viewHints config state.hint quiz.hints
    ]



{- case e.sync of
   Nothing ->
       Html.text ""
   Just { solved, resolved } ->
       Html.text
           ("solved: "
               ++ String.fromInt
                   (solved
                       + (if e.solved == Solution.Solved then
                           1
                          else
                           0
                         )
                   )
               ++ ", resolved: "
               ++ String.fromInt
                   (resolved
                       + (if e.solved == Solution.ReSolved then
                           1
                          else
                           0
                         )
                   )
           )
-}


viewFeedback : Lang -> Element -> Html msg
viewFeedback lang state =
    if state.error_msg /= "" then
        Html.div [ Attr.class "lia-quiz__feedback text-error" ]
            [ Html.text state.error_msg
            ]

    else
        case state.solved of
            Solution.Solved ->
                Html.div [ Attr.class "lia-quiz__feedback text-success" ]
                    -- TODO: maybe lable success, failure, ... locale independend
                    [ lang
                        |> quizAnswerSuccess
                        |> Html.text
                    ]

            Solution.ReSolved ->
                Html.div [ Attr.class "lia-quiz__feedback text-disabled" ]
                    [ lang
                        |> quizAnswerResolved
                        |> Html.text
                    ]

            Solution.Open ->
                if state.trial == 0 then
                    Html.text ""

                else
                    Html.div [ Attr.class "lia-quiz__feedback text-error" ]
                        [ lang
                            |> quizAnswerError
                            |> Html.text
                        ]


{-| **private:** Show the solution button only if the quiz has not been solved
yet.
-}
viewSolutionButton : { config : Config sub, hidden : Bool, solution : Solution, msg : Msg sub } -> Html (Msg sub)
viewSolutionButton { config, hidden, solution, msg } =
    btnIcon
        { title = quizSolution config.lang
        , msg =
            if solution == Solution.Open then
                Just msg

            else
                Nothing
        , tabbable = not hidden && solution == Solution.Open
        , icon = "icon-resolve"
        }
        [ Attr.classList
            [ ( "lia-btn--transparent lia-quiz__resolve", True )
            , ( "hide", hidden )
            ]
        , A11y_Widget.label (quizLabelSolution config.lang)
        ]


{-| **private:** Show the main check-button to compare the current state of the
quiz with the solution state. The number of trials is automatically added.
-}
viewMainButton : Config sub -> Int -> Solution -> Msg sub -> Html (Msg sub)
viewMainButton config trials solution msg =
    btn
        { title = ""
        , msg =
            if solution == Solution.Open then
                Just msg

            else
                Nothing
        , tabbable = solution == Solution.Open
        }
        [ Attr.class "lia-btn--outline lia-quiz__check", A11y_Widget.label (quizLabelCheck config.lang) ]
        [ Html.text (quizCheck config.lang)
        , Html.text <|
            if trials > 0 then
                " " ++ String.fromInt trials

            else
                ""
        ]


{-| **private:** If hints have been added to the quiz by `[[?]]` these will
shown within a list and an additional button will be displayed to reveal more
hints, if there are still hints not shown to the user and if the quiz has not
been solved yet.
-}
viewHints : Config sub -> Int -> List Inlines -> Html (Msg sub)
viewHints config counter hints =
    if List.isEmpty hints then
        Html.text ""

    else
        hints
            |> List.take counter
            |> List.map (viewer config >> Html.li [])
            |> Html.ul [ Attr.class "lia-list--unordered lia-quiz__hints" ]
            |> Html.map Script


{-| **private:** Show a generic hint button, every time it is clicked it will
reveal another hint from the list.
-}
viewHintButton : { id : Int, show : Bool, active : Bool, title : String } -> Html (Msg sub)
viewHintButton { id, show, active, title } =
    if show then
        btnIcon
            { title = title
            , msg =
                if active then
                    Just (ShowHint id)

                else
                    Nothing
            , icon = "icon-hint"
            , tabbable = True
            }
            [ Attr.class "lia-btn--transparent lia-quiz__hint", A11y_Role.button ]

    else
        Html.text ""


{-| Check the state of quiz:
Open -> False
Solved -> True
Resolved -> True
-}
showSolution : Quiz x -> Vector -> Bool
showSolution quiz =
    Array.get quiz.id
        >> Maybe.map isSolved
        >> Maybe.withDefault False
