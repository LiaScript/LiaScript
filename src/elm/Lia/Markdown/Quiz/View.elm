module Lia.Markdown.Quiz.View exposing
    ( class
    , maybeConfig
    , openState
    , showSolution
    , syncAttributes
    , view
    , viewMatrixTableSync
    , viewTableSync
    )

{-| This module defines the basic frame for all subsequent and specialized
quizzes. It adds a common check button, hint button, and solution button,
shows hints and feedback and, within a classroom, the results of all peers.
-}

import Accessibility.Aria as A11y_Aria
import Accessibility.Live as A11y_Live
import Accessibility.Role as A11y_Role
import Array
import Conditional.List as CList
import Dict exposing (Dict)
import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import I18n.Translations as Translations
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
import Json.Encode as JE
import Lia.Markdown.Chart.View as Chart
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Quiz.Block.Update as BlockMsg
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
import Lia.Markdown.Update as Main
import Lia.Sync.Types as Sync
import Lia.Utils
    exposing
        ( btn
        , btnIcon
        , percentage
        , shuffle
        , viewIdenticon
        )
import List.Extra


{-| Size and class of all classroom diagrams, also used by surveys.
-}
syncAttributes : List ( String, String )
syncAttributes =
    [ ( "style", "height: 150px; width: 100%" ), ( "class", "lia-quiz__sync" ) ]


{-| Main Quiz view function. `renderedOptions` (used only for `Vector_Type`) and
`renderedHints` are pre-rendered by the caller (`Lia.Markdown.View`, which
recursively renders nested `Block` content via `viewBlocks`), since the block
content may itself contain arbitrary Markdown constructs that only the top-level
renderer knows how to display.
-}
view : Config Main.Msg -> Maybe String -> Quiz Markdown.Block -> Vector -> List (List (Html Main.Msg)) -> List (List (Html Main.Msg)) -> ( Maybe Int, List (Html Main.Msg) )
view config labeledBy quiz vector renderedOptions renderedHints =
    case Array.get quiz.id vector of
        Just elem ->
            ( elem.scriptID
            , viewState config elem quiz renderedOptions
                |> viewQuiz config labeledBy elem quiz renderedHints
                |> viewSync config (Sync.get config.sync .quiz config.slide quiz.id) elem.opt.score
            )

        _ ->
            ( Nothing, [] )


{-| A gap-text quiz (`Multi_Type`) is rendered as its block, with the inputs
being part of the inline elements. This returns the config, which contains the
input states, together with that block and the random order of the options.
-}
maybeConfig : Config Main.Msg -> Quiz Markdown.Block -> Vector -> Maybe ( Config Main.Msg, Markdown.Block, Maybe (List Int) )
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
                            , randomize = elem.opt.randomize
                            }
                    of
                        ( newConfig, Just block ) ->
                            Just ( newConfig, block, elem.opt.randomize )

                        _ ->
                            Nothing

                _ ->
                    Nothing

        _ ->
            Nothing


{-| **private:** A colored icon, optionally followed by a text.
-}
iconWithColor : String -> String -> Maybe String -> Html msg
iconWithColor icon color text =
    Html.span []
        [ Html.span
            [ Attr.style "color" color
            , Attr.style "margin-right" <|
                if text == Nothing then
                    "0"

                else
                    "0.5rem"
            ]
            [ Html.text icon ]
        , text
            |> Maybe.withDefault ""
            |> Html.text
        ]


{-| **private:** Compact cells for the classroom tables.
-}
tablePadding : Html.Attribute msg
tablePadding =
    Attr.style "padding" "0px 5px !important"


{-| **private:** A header cell of the classroom tables.
-}
tableHeaderCell : List (Html.Attribute msg) -> String -> Html msg
tableHeaderCell attrs text =
    Html.th (Attr.class "lia-table__header" :: tablePadding :: attrs) [ Html.text text ]


{-| **private:** The columns every classroom table starts with.
-}
fixedHeaderCells : List (Html.Attribute msg) -> List (Html msg)
fixedHeaderCells attrs =
    [ "User", "Online", "State" ] |> List.map (tableHeaderCell attrs)


{-| The owner's details table of all peers in a classroom, appended to `quiz`:
one row per peer with its name, online state, answered state and the cells of
`visualize` (one per `headers` entry). Other peers see `quiz` only.
-}
viewTableSync :
    Sync.Settings
    -> List String
    -> (String -> Dict String x -> List (Html msg))
    -> Dict String x
    -> List (Html msg)
    -> List (Html msg)
viewTableSync syncSettings headers =
    viewTableSyncWith syncSettings
        (List.length headers)
        [ (fixedHeaderCells [] ++ (headers |> List.map (tableHeaderCell [])))
            |> Html.tr []
        ]


{-| Matrix survey tables get a two-row header: one cell per main statement
spanning all of its option columns, with the option labels as a sub-header
underneath. `groups` must stay in the same (statement, options) order the
`toStringFn`-flattened cells are emitted in, since the two are not linked by
anything but call-site convention.
-}
viewMatrixTableSync :
    Sync.Settings
    -> List ( String, List String )
    -> (String -> Dict String x -> List (Html msg))
    -> Dict String x
    -> List (Html msg)
    -> List (Html msg)
viewMatrixTableSync syncSettings groups =
    viewTableSyncWith syncSettings
        (groups |> List.concatMap Tuple.second |> List.length)
        [ (fixedHeaderCells [ Attr.rowspan 2 ]
            ++ (groups
                    |> List.map
                        (\( statement, options ) ->
                            -- kept to a single line (ellipsis + title for the
                            -- full text) so its rendered height stays
                            -- predictable -- the sub-header row below relies
                            -- on that height to compute its own sticky offset.
                            tableHeaderCell
                                [ Attr.colspan (List.length options)
                                , Attr.title statement
                                , Attr.style "white-space" "nowrap"
                                , Attr.style "overflow" "hidden"
                                , Attr.style "text-overflow" "ellipsis"
                                ]
                                statement
                        )
               )
          )
            |> Html.tr []
        , groups
            |> List.concatMap (Tuple.second >> List.map (tableHeaderCell []))
            |> Html.tr [ Attr.class "lia-table__head-row--sub" ]
        ]


{-| **private:** `viewTableSync` with any header rows, `columnCount` is the
number of cells `visualize` returns, used for the empty cells of peers that
have not answered yet.
-}
viewTableSyncWith :
    Sync.Settings
    -> Int
    -> List (Html msg)
    -> (String -> Dict String x -> List (Html msg))
    -> Dict String x
    -> List (Html msg)
    -> List (Html msg)
viewTableSyncWith syncSettings columnCount headerRows visualize data quiz =
    let
        peers =
            Sync.roster syncSettings data

        isPending bool =
            Html.td
                [ Attr.class "lia-table__data"
                , tablePadding
                , Attr.style "text-align" "center"
                ]
                [ if bool then
                    iconWithColor "◉" "orange" (Just "Open")

                  else
                    iconWithColor "◉" "gray" (Just "Done")
                ]
    in
    if Sync.isRoot syncSettings then
        [ Html.details [ Attr.style "margin-top" "1rem" ]
            [ Html.summary
                [ tablePadding
                , Attr.style "margin" "0"
                ]
                [ Html.text "details" ]
            , Html.div
                [ Attr.class "lia-table-responsive has-thead-sticky has-first-col-sticky"
                , Attr.style "max-height" "300px"
                , Attr.style "padding" "0"
                ]
                [ Html.table
                    [ Attr.class "lia-table is-compact"
                    ]
                    [ Html.thead [ Attr.class "lia-table__head" ] headerRows
                    , peers
                        |> Dict.toList
                        |> List.map
                            (\( id, name ) ->
                                Html.td
                                    [ Attr.class "lia-table__data"
                                    , tablePadding
                                    ]
                                    [ Html.text name, viewIdenticon id ]
                                    :: Html.td
                                        [ Attr.class "lia-table__data"
                                        , tablePadding
                                        , Attr.style "text-align" "center"
                                        ]
                                        [ if Dict.member id syncSettings.peers then
                                            iconWithColor "●" "green" (Just "On")

                                          else
                                            iconWithColor "●" "red" (Just "Off")
                                        ]
                                    :: (if Dict.member id data then
                                            visualize id data
                                                |> List.map
                                                    (List.singleton
                                                        >> Html.td
                                                            [ Attr.class "lia-table__data"
                                                            , Attr.style "text-align" "center"
                                                            , tablePadding
                                                            ]
                                                    )
                                                |> (::) (isPending False)

                                        else
                                            Html.td [ Attr.class "lia-table__data", tablePadding ] []
                                                |> List.repeat columnCount
                                                |> (::) (isPending True)
                                       )
                                    |> Html.tr [ Attr.class "lia-table__row" ]
                            )
                        |> Html.tbody [ Attr.class "lia-table__body" ]
                    ]
                ]
            ]
        ]
            |> List.append quiz

    else
        quiz


{-| **private:** Bar chart of the trials needed by all peers, resolved quizzes
are gray, the owner also sees the peers that have not answered yet.
-}
syncDiagram : Config sub -> Sync.Settings -> Dict String (Maybe Int) -> Html msg
syncDiagram config sync data =
    let
        owner =
            Sync.isRoot sync

        total =
            toFloat <|
                if owner then
                    Dict.size (Sync.roster sync data)

                else
                    Dict.size data

        chartData =
            data
                |> Dict.values
                |> List.Extra.gatherEquals
                |> List.map
                    (\( i, list ) ->
                        let
                            absolute =
                                1 + List.length list
                        in
                        case i of
                            Just i_ ->
                                bar ("Trial " ++ String.fromInt i_) Nothing absolute (percentage total absolute) []

                            Nothing ->
                                bar "Resolved" (Just "#888") absolute (percentage total absolute) []
                    )
                |> CList.addIf owner (openState sync data)
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
                , ( "data", JE.list Tuple.first chartData )
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
              , ( "data", JE.list Tuple.second chartData )
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


{-| **private:** A labeled bar of the classroom diagrams, the label shows the
absolute and the relative value. `label` adds further label settings in
front.
-}
bar : String -> Maybe String -> Int -> Float -> List ( String, JE.Value ) -> ( JE.Value, JE.Value )
bar name color absolute relative label =
    ( JE.string name
    , [ ( "value", JE.float relative ) ]
        ++ (case color of
                Just c ->
                    [ ( "itemStyle", JE.object [ ( "color", JE.string c ) ] ) ]

                Nothing ->
                    []
           )
        ++ [ ( "label"
             , JE.object
                (label
                    ++ [ ( "show", JE.bool True )
                       , ( "formatter"
                         , String.fromInt absolute
                            ++ " ("
                            ++ String.fromFloat relative
                            ++ "%)"
                            |> JE.string
                         )
                       ]
                )
             )
           ]
        |> JE.object
    )


{-| The "Open" bar of the classroom diagrams, all peers of the roster that have
not answered (are not part of `data`). Also used by surveys.
-}
openState : Sync.Settings -> Dict String x -> ( JE.Value, JE.Value )
openState sync data =
    let
        total =
            Sync.roster sync data
                |> Dict.size

        open =
            total - Dict.size data
    in
    bar "Open"
        (Just "#FDBA74")
        open
        (percentage (toFloat total) open)
        (if open == 0 then
            -- keep the label of an empty bar above the axis
            [ ( "distance", JE.int 6 ), ( "position", JE.string "top" ) ]

         else
            []
        )


{-| **private:** Within a classroom add the diagram and the details table of
the peers' results to the `quiz` view. Peers only see the diagram, after
somebody has answered.
-}
viewSync : Config sub -> Maybe (Dict String Sync) -> Maybe Float -> List (Html msg) -> List (Html msg)
viewSync config syncData score quiz =
    case config.sync of
        Just sync ->
            let
                data =
                    Maybe.withDefault Dict.empty syncData

                visualize id =
                    Dict.get id >> Maybe.map .trial >> visualizeTrial score
            in
            (if Dict.isEmpty data && not (Sync.isRoot sync) then
                quiz

             else
                quiz ++ [ syncDiagram config sync (Dict.map (\_ v -> v.trial) data) ]
            )
                |> viewTableSync sync [ "Answered", "Trial", "Score" ] visualize data

        Nothing ->
            quiz


{-| **private:** The table cells of a peer's answer: solved after n trials or
resolved, or nothing if not answered.
-}
visualizeTrial : Maybe Float -> Maybe (Maybe Int) -> List (Html msg)
visualizeTrial score answer =
    case answer of
        Just (Just trial) ->
            [ iconWithColor "✓" "#5470c6" Nothing
            , Html.text <| String.fromInt trial
            , score
                |> Maybe.map String.fromFloat
                |> Maybe.withDefault "1.0"
                |> Html.text
            ]

        Just Nothing ->
            [ iconWithColor "✗" "#888" Nothing
            , Html.text ""
            , Html.text "0.0"
            ]

        Nothing ->
            []


{-| The classes of a quiz container: its type and its solution state, e.g.
`lia-quiz lia-quiz-select open`.
-}
class : Int -> Vector -> String
class id =
    Array.get id
        >> Maybe.map (\s -> "lia-quiz-" ++ getClass s.state ++ " " ++ Solution.toString s.solved)
        >> Maybe.withDefault ""
        >> (++) "lia-quiz "


{-| **private:** Simple router function that is used to match the current state
of a quiz with its type. `renderedOptions` is only used by the `Vector_Type`
branch (pre-rendered option content, see `view`).
-}
viewState :
    Config Main.Msg
    -> Element
    -> Quiz Markdown.Block
    -> List (List (Html Main.Msg))
    -> ( List (Attribute Main.Msg), List (Html Main.Msg) )
viewState config elem quiz renderedOptions =
    case ( elem.state, quiz.quiz ) of
        ( Block_State s, Block_Type q ) ->
            ( []
            , s
                |> Block.view config elem.opt.randomize ( elem.solved, elem.trial ) q
                |> List.map
                    (Html.map
                        (\msg ->
                            Main.UpdateQuiz <|
                                case msg of
                                    BlockMsg.Submit ->
                                        if elem.deactivated then
                                            Block_Update quiz.id BlockMsg.None

                                        else
                                            Check quiz.id quiz.quiz

                                    _ ->
                                        Block_Update quiz.id msg
                        )
                    )
            )

        ( Vector_State s, Vector_Type q ) ->
            Vector.view
                ("lia-quiz-" ++ String.fromInt config.slide ++ "-" ++ String.fromInt quiz.id)
                (elem.solved == Solution.Open)
                (Solution.toClass ( elem.solved, elem.trial ) Nothing)
                quiz.id
                q
                s
                renderedOptions
                |> Tuple.mapSecond (shuffle elem.opt.randomize)

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
                    |> Html.map (Matrix_Update quiz.id >> Main.UpdateQuiz)
              ]
            )

        _ ->
            ( [], [] )


{-| **private:** Return the current quiz as list of elements that contains:

1.  the body of the quiz itself, which might be of type `Block`, `Vector`, or
    `Matrix`
2.  the controls: the check button, the solution button and the hint button
3.  the feedback, including error messages of a checking script
4.  the list of already revealed hints

-}
viewQuiz :
    Config Main.Msg
    -> Maybe String
    -> Element
    -> Quiz Markdown.Block
    -> List (List (Html Main.Msg))
    -> ( List (Attribute Main.Msg), List (Html Main.Msg) )
    -> List (Html Main.Msg)
viewQuiz config labeledBy state quiz renderedHints ( attr, body ) =
    [ Html.div
        (Attr.class "lia-quiz__answers"
            :: (labeledBy
                    |> Maybe.map A11y_Aria.labelledBy
                    |> Maybe.withDefault (Attr.class "")
               )
            -- aria-labelledby is ignored on elements without a role
            :: (if List.isEmpty attr then
                    [ A11y_Role.group ]

                else
                    attr
               )
            |> CList.addIf (state.solved == Solution.ReSolved) A11y_Live.polite
        )
        body
    , Html.div [ Attr.class "lia-quiz__control" ]
        [ viewMainButton config state.trial state.deactivated state.solved quiz.id quiz.quiz
        , viewSolutionButton
            { config = config
            , solution = state.solved
            , msg = Main.UpdateQuiz (ShowSolution quiz.id quiz.quiz)
            , hidden = state.trial < state.opt.showResolveAt
            , deactivated = state.deactivated
            }
        , viewHintButton
            { id = quiz.id
            , show = (quiz.hints /= []) && (state.trial >= state.opt.showHintsAt)
            , active = Solution.Open == state.solved && state.hint < List.length quiz.hints && not state.deactivated
            , title = Translations.quizHint config.lang
            }
        ]
    , viewFeedback config quiz.id state
    , viewHints quiz.id state.hint renderedHints
    ]


{-| **private:** The feedback after a check, custom texts (`data-text-solved`,
`data-text-failed`, `data-text-resolved`) replace the default ones. Error
messages of a checking script have precedence.
-}
viewFeedback : Config Main.Msg -> Int -> Element -> Html Main.Msg
viewFeedback config id state =
    let
        feedback color =
            Html.div
                [ Attr.class ("lia-quiz__feedback " ++ color)
                , Attr.id ("lia-quiz-feedback-" ++ String.fromInt id)
                , A11y_Live.polite
                ]
    in
    if state.error_msg /= "" then
        feedback "text-error"
            [ Html.text state.error_msg
            ]

    else
        case state.solved of
            Solution.Solved ->
                feedback "text-success"
                    -- TODO: maybe lable success, failure, ... locale independend
                    [ showCustomFeedback
                        config
                        state.opt.text_solved
                        quizAnswerSuccess
                    ]

            Solution.ReSolved ->
                feedback "text-disabled"
                    [ showCustomFeedback
                        config
                        state.opt.text_resolved
                        quizAnswerResolved
                    ]

            Solution.Open ->
                if state.trial == 0 then
                    Html.text ""

                else
                    feedback "text-error"
                        [ showCustomFeedback
                            config
                            state.opt.text_failed
                            quizAnswerError
                        ]


{-| **private:** Show the `custom` feedback text, if defined, otherwise the
translated default.
-}
showCustomFeedback : Config Main.Msg -> Maybe Inlines -> (Lang -> String) -> Html Main.Msg
showCustomFeedback config custom default =
    custom
        |> Maybe.map
            (viewer config
                >> Html.div []
                >> Html.map (Script >> Main.UpdateQuiz)
            )
        |> Maybe.withDefault
            (config.lang
                |> default
                |> Html.text
            )


{-| **private:** Show the solution button only if the quiz has not been solved
yet.
-}
viewSolutionButton : { config : Config Main.Msg, hidden : Bool, solution : Solution, msg : Main.Msg, deactivated : Bool } -> Html Main.Msg
viewSolutionButton { config, hidden, solution, msg, deactivated } =
    btnIcon
        { title = quizSolution config.lang
        , msg =
            if solution == Solution.Open && not deactivated then
                Just msg

            else
                Nothing
        , tabbable = not hidden
        , icon = "icon-resolve"
        }
        [ Attr.classList
            [ ( "lia-btn--transparent lia-quiz__resolve", True )
            , ( "hide", hidden )
            ]
        , A11y_Aria.label (quizLabelSolution config.lang)
        ]


{-| **private:** Show the main check-button to compare the current state of the
quiz with the solution state. The number of trials is automatically added.
-}
viewMainButton : Config Main.Msg -> Int -> Bool -> Solution -> Int -> Type Markdown.Block -> Html Main.Msg
viewMainButton config trials isDeactivated solution quizId typeOf =
    btn
        { title = ""
        , msg =
            if solution == Solution.Open && not isDeactivated then
                Just (Main.UpdateQuiz (Check quizId typeOf))

            else
                Nothing
        , tabbable = True
        }
        [ Attr.class "lia-btn--outline lia-quiz__check", A11y_Aria.label (quizLabelCheck config.lang) ]
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
viewHints : Int -> Int -> List (List (Html Main.Msg)) -> Html Main.Msg
viewHints id counter hints =
    if List.isEmpty hints then
        Html.text ""

    else
        hints
            |> List.take counter
            |> List.map (Html.li [])
            |> Html.ul
                [ Attr.class "lia-list--unordered lia-quiz__hints"
                , Attr.id ("lia-quiz-hints-" ++ String.fromInt id)
                , A11y_Live.polite
                ]


{-| **private:** Show a generic hint button, every time it is clicked it will
reveal another hint from the list.
-}
viewHintButton : { id : Int, show : Bool, active : Bool, title : String } -> Html Main.Msg
viewHintButton { id, show, active, title } =
    if show then
        btnIcon
            { title = title
            , msg =
                if active then
                    Just (Main.UpdateQuiz (ShowHint id))

                else
                    Nothing
            , icon = "icon-hint"
            , tabbable = True
            }
            [ Attr.class "lia-btn--transparent lia-quiz__hint", A11y_Role.button ]

    else
        Html.text ""


{-| Show the solution block (`*********`) of a quiz only if it has been solved
or resolved.
-}
showSolution : Quiz x -> Vector -> Bool
showSolution quiz =
    Array.get quiz.id
        >> Maybe.map isSolved
        >> Maybe.withDefault False
