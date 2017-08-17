module Lia.Helper
    exposing
        ( get_headers
        , get_slide
        , get_slide_effects
        , question_state
        , question_state_text
        , quiz_state
        , quiz_vector
        )

import Array
import Lia.Type exposing (Block(..), Quiz(..), QuizElement, QuizState(..), QuizVector, Slide)


get_headers : List Slide -> List ( Int, ( String, Int ) )
get_headers slides =
    slides
        |> List.map (\s -> ( s.title, s.indentation ))
        |> List.indexedMap (,)


get_slide : Int -> List Slide -> Maybe Slide
get_slide i slides =
    case ( i, slides ) of
        ( _, [] ) ->
            Nothing

        ( 0, x :: xs ) ->
            Just x

        ( n, _ :: xs ) ->
            get_slide (n - 1) xs


get_slide_effects : Int -> List Slide -> Int
get_slide_effects i slides =
    case get_slide i slides of
        Just slide ->
            slide.effects

        Nothing ->
            0


quiz_vector : List Slide -> QuizVector
quiz_vector slides =
    let
        filter b =
            case b of
                Quiz quiz _ ->
                    Just quiz

                _ ->
                    Nothing

        vector quiz =
            let
                m =
                    case quiz of
                        TextInput str ->
                            Text "" str

                        SingleChoice a _ ->
                            Single -1 a

                        MultipleChoice q hints ->
                            q
                                |> List.map (\( b, _ ) -> ( False, b ))
                                |> Array.fromList
                                |> Multi
            in
            { solved = Nothing, state = m, trial = 0, hint = 0 }
    in
    slides
        |> List.map (\s -> s.body)
        |> List.concat
        |> List.filterMap filter
        |> List.map vector
        |> Array.fromList


quiz_state : Int -> QuizVector -> ( Maybe Bool, Int )
quiz_state quiz_id vector =
    vector
        |> Array.get quiz_id
        |> Maybe.andThen (\q -> Just ( q.solved, q.trial ))
        |> Maybe.withDefault ( Nothing, 0 )


question_state_text : Int -> QuizVector -> String
question_state_text quiz_id vector =
    case
        Array.get quiz_id vector
            |> Maybe.map .state
    of
        Just (Text input answer) ->
            input

        _ ->
            ""


question_state : Int -> Int -> QuizVector -> Bool
question_state quiz_id question_id vector =
    case
        Array.get quiz_id vector
            |> Maybe.map .state
    of
        Just (Single input answer) ->
            question_id == input

        Just (Multi questions) ->
            case Array.get question_id questions of
                Just ( c, _ ) ->
                    c

                Nothing ->
                    False

        _ ->
            False
