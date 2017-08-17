module Lia.Helper
    exposing
        ( get_headers
        , get_slide
        , get_slide_effects
        , question_state
        , question_state_text
        , quiz_matrix
        , quiz_state
        )

import Array
import Lia.Type exposing (Block(..), Quiz(..), QuizMatrix, QuizState(..), Slide)


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


quiz_matrix : List Slide -> QuizMatrix
quiz_matrix slides =
    let
        filter b =
            case b of
                Quiz quiz _ ->
                    Just quiz

                _ ->
                    Nothing

        matrix quiz =
            let
                m =
                    case quiz of
                        TextInput str ->
                            Text "" str

                        SingleChoice a _ ->
                            Single -1 a

                        MultipleChoice q ->
                            q
                                |> List.map (\( b, _ ) -> ( False, b ))
                                |> Array.fromList
                                |> Multi
            in
            ( Nothing, m, 0 )
    in
    slides
        |> List.map (\s -> s.body)
        |> List.concat
        |> List.filterMap filter
        |> List.map matrix
        |> Array.fromList


quiz_state : Int -> QuizMatrix -> ( Maybe Bool, Int )
quiz_state quiz_id matrix =
    case Array.get quiz_id matrix of
        Just ( state, _, trial_count ) ->
            ( state, trial_count )

        Nothing ->
            ( Nothing, 0 )


question_state_text : Int -> QuizMatrix -> String
question_state_text quiz_id matrix =
    case Array.get quiz_id matrix of
        Just ( _, Text input answer, _ ) ->
            input

        _ ->
            ""


question_state : Int -> Int -> QuizMatrix -> Bool
question_state quiz_id question_id matrix =
    case Array.get quiz_id matrix of
        Just ( _, Single input answer, _ ) ->
            question_id == input

        Just ( _, Multi questions, _ ) ->
            case Array.get question_id questions of
                Just ( c, _ ) ->
                    c

                Nothing ->
                    False

        _ ->
            False
