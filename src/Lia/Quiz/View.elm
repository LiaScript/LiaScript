module Lia.Quiz.View exposing (view, view_solution)

import Array exposing (Array)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia.Markdown.Inline.Types exposing (Annotation, MultInlines)
import Lia.Markdown.Inline.View exposing (annotation, view_inf)
import Lia.Quiz.Model exposing (..)
import Lia.Quiz.Types exposing (..)
import Lia.Quiz.Update exposing (Msg(..))


view : Bool -> Annotation -> Quiz -> Vector -> Html Msg
view show_solution attr quiz vector =
    let
        state =
            get_state vector
    in
    case quiz of
        Text solution idx hints ->
            view_quiz attr show_solution (state idx) view_text idx hints (TextState solution)

        SingleChoice solution questions idx hints ->
            view_quiz attr show_solution (state idx) (view_single_choice questions) idx hints (SingleChoiceState solution)

        MultipleChoice solution questions idx hints ->
            view_quiz attr show_solution (state idx) (view_multiple_choice questions) idx hints (MultipleChoiceState solution)


view_quiz : Annotation -> Bool -> Maybe Element -> (Int -> State -> Bool -> Html Msg) -> Int -> MultInlines -> State -> Html Msg
view_quiz attr show_solution state fn_view idx hints solution =
    case state of
        Just s ->
            Html.p (annotation attr "lia-quiz")
                (fn_view idx s.state (s.solved /= Open)
                    :: view_button s.trial s.solved (Check idx solution)
                    :: (if show_solution then
                            Html.a
                                [ Attr.class "lia-hint-btn"
                                , Attr.href "#"
                                , onClick (ShowSolution idx solution)
                                , Attr.title "show solution"
                                ]
                                [ Html.text "info" ]
                        else
                            Html.text ""
                       )
                    :: view_hints idx s.hint hints
                )

        Nothing ->
            Html.text ""


view_button : Int -> Solution -> Msg -> Html Msg
view_button trials solved msg =
    case solved of
        Open ->
            if trials == 0 then
                Html.button [ Attr.class "lia-btn", onClick msg ] [ Html.text "Check" ]
            else
                Html.button
                    [ Attr.class "lia-btn", Attr.class "lia-failure", onClick msg ]
                    [ Html.text ("Check " ++ toString trials) ]

        Solved ->
            Html.button
                [ Attr.class "lia-btn", Attr.class "lia-success" ]
                [ Html.text ("Check " ++ toString trials) ]

        ReSolved ->
            Html.button
                [ Attr.class "lia-btn", Attr.class "lia-failure" ]
                [ Html.text "Resolved" ]


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
                |> List.indexedMap (,)
                |> List.map
                    (\( i, elements ) ->
                        Html.p [ Attr.class "lia-radio-item" ]
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
                            , Html.span [ Attr.class "lia-label" ] (List.map view_inf elements)
                            ]
                    )
                |> Html.div []

        _ ->
            Html.text ""


view_multiple_choice : MultInlines -> Int -> State -> Bool -> Html Msg
view_multiple_choice questions idx state solved =
    let
        fn b ( i, line ) =
            Html.p [ Attr.class "lia-check-item" ]
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
                , Html.span [ Attr.class "lia-label" ] (List.map view_inf line)
                ]
    in
    case state of
        MultipleChoiceState x ->
            questions
                |> List.indexedMap (,)
                |> List.map2 fn (Array.toList x)
                |> Html.div []

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


view_solution : Vector -> Quiz -> Bool
view_solution vector quiz =
    let
        idx =
            case quiz of
                Text _ idx _ ->
                    idx

                SingleChoice _ _ idx _ ->
                    idx

                MultipleChoice _ _ idx _ ->
                    idx
    in
    idx
        |> get_state vector
        |> Maybe.map .solved
        |> Maybe.map (\s -> s /= Open)
        |> Maybe.withDefault False
