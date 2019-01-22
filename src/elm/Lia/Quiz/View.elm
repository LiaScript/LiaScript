module Lia.Quiz.View exposing (view, view_solution)

--import Lia.Code.View exposing (error)

import Array exposing (Array)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia.Markdown.Inline.Types exposing (Annotation, MultInlines)
import Lia.Markdown.Inline.View exposing (annotation, view_inf)
import Lia.Quiz.Model exposing (..)
import Lia.Quiz.Types exposing (..)
import Lia.Quiz.Update exposing (Msg(..))
import Translations exposing (Lang, quizCheck, quizChecked, quizResolved, quizSolution)


view : Lang -> Annotation -> Quiz -> Vector -> Html Msg
view lang attr quiz vector =
    let
        state =
            get_state vector
    in
    case quiz of
        Empty (QuizAdds idx hints eval_string) ->
            case state idx of
                Just s ->
                    (case eval_string of
                        Just code ->
                            view_button lang s.trial s.solved (Check idx s.state eval_string)

                        Nothing ->
                            Html.text ""
                    )
                        :: view_button_solution lang s.solved (ShowSolution idx EmptyState)
                        :: (if s.error_msg == "" then
                                Html.text ""

                            else
                                Html.br [] []
                           )
                        :: (if s.error_msg == "" then
                                Html.text ""

                            else
                                --todo: error s.error_msg
                                Html.text s.error_msg
                           )
                        :: view_hints idx s.hint hints
                        |> Html.div []

                Nothing ->
                    Html.text ""

        Text solution (QuizAdds idx hints eval_string) ->
            view_quiz lang attr (state idx) view_text idx hints eval_string (TextState solution)

        SingleChoice solution questions (QuizAdds idx hints eval_string) ->
            view_quiz lang attr (state idx) (view_single_choice questions) idx hints eval_string (SingleChoiceState solution)

        MultipleChoice solution questions (QuizAdds idx hints eval_string) ->
            view_quiz lang attr (state idx) (view_multiple_choice questions) idx hints eval_string (MultipleChoiceState solution)


view_quiz : Lang -> Annotation -> Maybe Element -> (Int -> State -> Bool -> Html Msg) -> Int -> MultInlines -> Maybe String -> State -> Html Msg
view_quiz lang attr state fn_view idx hints eval_string solution =
    case state of
        Just s ->
            Html.p (annotation "" attr)
                (fn_view idx s.state (s.solved /= Open)
                    :: view_button lang s.trial s.solved (Check idx solution eval_string)
                    :: view_button_solution lang s.solved (ShowSolution idx solution)
                    :: (if s.error_msg == "" then
                            Html.text ""

                        else
                            Html.br [] []
                       )
                    :: (if s.error_msg == "" then
                            Html.text ""

                        else
                            --todo error s.error_msg
                            Html.text s.error_msg
                       )
                    :: view_hints idx s.hint hints
                )

        Nothing ->
            Html.text ""


view_button_solution : Lang -> Solution -> Msg -> Html Msg
view_button_solution lang solution msg =
    if solution == Open then
        Html.a
            [ Attr.class "lia-hint-btn"
            , Attr.href "#"
            , onClick msg
            , Attr.title (quizSolution lang)
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


view_text : Int -> State -> Bool -> Html Msg
view_text idx state solved =
    case state of
        TextState x ->
            Html.input
                [ Attr.type_ "input"
                , Attr.class "lia-input"
                , Attr.value x
                , Attr.disabled solved
                , onInput (Input idx)
                ]
                []

        _ ->
            Html.text ""


view_single_choice : MultInlines -> Int -> State -> Bool -> Html Msg
view_single_choice questions idx state solved =
    case state of
        SingleChoiceState x ->
            questions
                |> List.indexedMap Tuple.pair
                |> List.map
                    (\( i, elements ) ->
                        Html.tr [ Attr.class "lia-radio-item" ]
                            [ Html.td [ Attr.attribute "valign" "top", Attr.class "lia-label" ]
                                [ Html.input
                                    [ Attr.type_ "radio"
                                    , Attr.checked (i == x)
                                    , if solved then
                                        Attr.disabled True

                                      else
                                        onClick (RadioButton idx i)
                                    ]
                                    []
                                , Html.span [ Attr.class "lia-radio-btn" ] []
                                ]
                            , Html.td
                                [ Attr.class "lia-label" ]
                                (List.map view_inf elements)
                            ]
                    )
                |> Html.table [ Attr.attribute "cellspacing" "8" ]

        _ ->
            Html.text ""


view_multiple_choice : MultInlines -> Int -> State -> Bool -> Html Msg
view_multiple_choice questions idx state solved =
    let
        fn b ( i, line ) =
            Html.tr [ Attr.class "lia-check-item" ]
                [ Html.td [ Attr.attribute "valign" "top", Attr.class "lia-label" ]
                    [ Html.input
                        [ Attr.type_ "checkbox"
                        , Attr.checked b
                        , if solved then
                            Attr.disabled True

                          else
                            onClick (RadioButton idx i)
                        ]
                        []
                    , Html.span [ Attr.class "lia-check-btn" ] [ Html.text "check" ]
                    ]
                , Html.td [ Attr.class "lia-label" ] (List.map view_inf line)
                ]
    in
    case state of
        MultipleChoiceState x ->
            questions
                |> List.indexedMap Tuple.pair
                |> List.map2 fn x
                |> Html.table [ Attr.attribute "cellspacing" "8" ]

        _ ->
            Html.text ""


view_hints : Int -> Int -> MultInlines -> List (Html Msg)
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
        [ Html.text " "
        , Html.a
            [ Attr.class "lia-hint-btn"
            , Attr.href "#"
            , onClick (ShowHint idx)
            , Attr.title "show hint"
            ]
            [ Html.text "help" ]
        , Html.div
            [ Attr.class "lia-hints"
            ]
            (v_hints hints counter)
        ]

    else
        [ Html.div
            [ Attr.class "lia-hints"
            ]
            (v_hints hints counter)
        ]


view_solution : Vector -> Quiz -> ( Bool, Bool )
view_solution vector quiz =
    let
        ( idx_, empty ) =
            case quiz of
                Empty (QuizAdds idx _ _) ->
                    ( idx, True )

                Text _ (QuizAdds idx _ _) ->
                    ( idx, False )

                SingleChoice _ _ (QuizAdds idx _ _) ->
                    ( idx, False )

                MultipleChoice _ _ (QuizAdds idx _ _) ->
                    ( idx, False )
    in
    idx_
        |> get_state vector
        |> Maybe.map .solved
        |> Maybe.map (\s -> s /= Open)
        |> Maybe.withDefault False
        |> Tuple.pair empty
