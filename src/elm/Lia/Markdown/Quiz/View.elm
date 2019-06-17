module Lia.Markdown.Quiz.View exposing (view, view_solution)

--import Lia.Code.View exposing (error)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia.Markdown.Inline.Types exposing (Annotation, MultInlines)
import Lia.Markdown.Inline.View exposing (annotation, view_inf)
import Lia.Markdown.Quiz.Model exposing (get_state)
import Lia.Markdown.Quiz.Types exposing (Element, Quiz(..), QuizAdds(..), Solution(..), State(..), Vector)
import Lia.Markdown.Quiz.Update exposing (Msg(..))
import Translations exposing (Lang, quizCheck, quizChecked, quizResolved, quizSolution)


view : Lang -> Quiz -> Vector -> Html Msg
view lang quiz vector =
    let
        state =
            get_state vector
    in
    case quiz of
        Empty (QuizAdds idx hints eval_string) ->
            case state idx of
                Just s ->
                    (case eval_string of
                        Just _ ->
                            view_button lang s.trial s.solved (Check idx s.state eval_string)

                        Nothing ->
                            Html.text ""
                    )
                        :: view_button_solution lang s.solved (ShowSolution idx State_Empty)
                        :: (if s.error_msg == "" then
                                Html.text ""

                            else
                                Html.br [] []
                           )
                        :: (if s.error_msg == "" then
                                Html.text ""

                            else
                                Html.text s.error_msg
                           )
                        :: view_hints idx s.hint hints
                        |> Html.div []

                Nothing ->
                    Html.text ""

        Text solution (QuizAdds idx hints eval_string) ->
            view_quiz lang (state idx) view_text idx hints eval_string (State_Text solution)

        Selection solution options (QuizAdds idx hints eval_string) ->
            view_quiz lang (state idx) (view_selection options) idx hints eval_string (State_Selection solution)

        SingleChoice solution questions (QuizAdds idx hints eval_string) ->
            view_quiz lang (state idx) (view_single_choice questions) idx hints eval_string (State_SingleChoice solution)

        MultipleChoice solution questions (QuizAdds idx hints eval_string) ->
            view_quiz lang (state idx) (view_multiple_choice questions) idx hints eval_string (State_MultipleChoice solution)


view_quiz : Lang -> Maybe Element -> (Int -> State -> Bool -> Html Msg) -> Int -> MultInlines -> Maybe String -> State -> Html Msg
view_quiz lang state fn_view idx hints eval_string solution =
    case state of
        Just s ->
            Html.p []
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
                            Html.text s.error_msg
                       )
                    :: view_hints idx s.hint hints
                )

        Nothing ->
            Html.text ""


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


view_text : Int -> State -> Bool -> Html Msg
view_text idx state solved =
    case state of
        State_Text x ->
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


option : String -> Int -> String -> Html Msg
option current val text =
    let
        str_val =
            String.fromInt val
    in
    Html.option
        [ Attr.value str_val
        , Attr.selected (str_val == current)
        ]
        [ Html.text text ]


view_selection : List String -> Int -> State -> Bool -> Html Msg
view_selection options idx state solved =
    case state of
        State_Selection x ->
            let
                fn =
                    option x
            in
            options
                |> List.indexedMap fn
                |> Html.select [ onInput <| Select idx ]

        _ ->
            Html.text ""


view_single_choice : MultInlines -> Int -> State -> Bool -> Html Msg
view_single_choice questions idx state solved =
    case state of
        State_SingleChoice x ->
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
        State_MultipleChoice x ->
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

                Selection _ _ (QuizAdds idx _ _) ->
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
