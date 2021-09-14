module Lia.Markdown.Survey.Model exposing
    ( getErrorMessage
    , get_matrix_state
    , get_select_state
    , get_submission_state
    , get_text_state
    , get_vector_state
    )

import Array
import Dict
import Lia.Markdown.Survey.Types exposing (Element(..), State(..), Sync, Vector)


getErrorMessage : Int -> Vector -> Maybe String
getErrorMessage id =
    Array.get id >> Maybe.andThen (\(Element _ _ message _) -> message)


get_submission_state : Vector -> Int -> Bool
get_submission_state vector idx =
    case Array.get idx vector of
        Just (Element True _ _ _) ->
            True

        _ ->
            False


get_text_state : Vector -> Int -> ( String, Maybe Sync )
get_text_state vector idx =
    case Array.get idx vector of
        Just (Element _ (Text_State str) _ sync) ->
            ( str, sync )

        _ ->
            ( "", Nothing )


get_vector_state : Vector -> Int -> String -> ( Maybe Float, Bool )
get_vector_state vector idx var =
    case Array.get idx vector of
        Just (Element _ (Vector_State _ state) _ Nothing) ->
            state
                |> Dict.get var
                |> Maybe.withDefault False
                |> Tuple.pair Nothing

        Just (Element _ (Vector_State b state) _ (Just sync)) ->
            let
                counter =
                    (if b then
                        Vector_State b state :: sync

                     else
                        sync
                    )
                        |> List.filter
                            (\syncedStates ->
                                case syncedStates of
                                    Vector_State _ syncedVector ->
                                        syncedVector
                                            |> Dict.get var
                                            |> Maybe.withDefault False

                                    _ ->
                                        False
                            )
                        |> List.length
                        |> toFloat
            in
            ( Just
                (100
                    * counter
                    / toFloat
                        ((if b then
                            1

                          else
                            0
                         )
                            + List.length sync
                        )
                )
            , state
                |> Dict.get var
                |> Maybe.withDefault False
            )

        _ ->
            ( Nothing, False )


get_select_state : Vector -> Int -> ( Bool, Int )
get_select_state vector id =
    case Array.get id vector of
        Just (Element _ (Select_State open value) _ _) ->
            ( open, value )

        _ ->
            ( False, -1 )


get_matrix_state : Vector -> Int -> Int -> String -> Bool
get_matrix_state vector idx row var =
    case Array.get idx vector of
        Just (Element _ (Matrix_State _ matrix) _ _) ->
            matrix
                |> Array.get row
                |> Maybe.andThen (\d -> Dict.get var d)
                |> Maybe.withDefault False

        _ ->
            False
