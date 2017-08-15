module Lia.Helper
    exposing
        ( get_headers
        , get_slide
        , question_state
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
                        SingleChoice a _ ->
                            Single -1 a

                        MultipleChoice q ->
                            q
                                |> List.map (\( b, _ ) -> ( False, b ))
                                |> Array.fromList
                                |> Multi
            in
            ( Nothing, m )
    in
    slides
        |> List.map (\s -> s.body)
        |> List.concat
        |> List.filterMap filter
        |> List.map matrix
        |> Array.fromList


quiz_state : Int -> QuizMatrix -> Maybe Bool
quiz_state quiz_id matrix =
    case Array.get quiz_id matrix of
        Just ( state, _ ) ->
            state

        Nothing ->
            Nothing


question_state : Int -> Int -> QuizMatrix -> Bool
question_state quiz_id question_id matrix =
    case Array.get quiz_id matrix of
        Just ( _, Single c a ) ->
            question_id == c

        Just ( _, Multi questions ) ->
            case Array.get question_id questions of
                Just ( c, _ ) ->
                    c

                Nothing ->
                    False

        _ ->
            False
