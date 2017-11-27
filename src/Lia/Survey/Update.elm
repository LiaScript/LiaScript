module Lia.Survey.Update exposing (Msg(..), update)

import Array
import Dict
import Json.Encode as JE
import Lia.Helper exposing (ID)
import Lia.Survey.Model exposing (Model, model2json)
import Lia.Survey.Types exposing (..)


--import Lia.Helper exposing (get_slide_effects)
--import Lia.Index
--import Lia.Model exposing (..)


type Msg
    = TextUpdate ID String
    | VectorUpdate ID String
    | MatrixUpdate ID ID String
    | Submit ID


update : Msg -> Model -> ( Model, Maybe JE.Value )
update msg model =
    case msg of
        TextUpdate idx str ->
            ( update_text model idx str, Nothing )

        VectorUpdate idx var ->
            ( update_vector model idx var, Nothing )

        MatrixUpdate idx row var ->
            ( update_matrix model idx row var, Nothing )

        Submit idx ->
            if submitable model idx then
                let
                    new_model =
                        submit model idx
                in
                ( new_model, Just <| model2json new_model )
            else
                ( model, Nothing )


update_text : Model -> ID -> String -> Model
update_text model idx str =
    case Array.get idx model of
        Just ( False, TextState _ ) ->
            set_state model idx (TextState str)

        _ ->
            model


update_vector : Model -> ID -> String -> Model
update_vector model idx var =
    case Array.get idx model of
        Just ( False, VectorState False vector ) ->
            vector
                |> Dict.map (\_ _ -> False)
                |> Dict.update var (\_ -> Just True)
                |> VectorState False
                |> set_state model idx

        Just ( False, VectorState True vector ) ->
            vector
                |> Dict.update var (\b -> Maybe.map not b)
                |> VectorState True
                |> set_state model idx

        _ ->
            model


update_matrix : Model -> ID -> ID -> String -> Model
update_matrix model idx row var =
    case Array.get idx model of
        Just ( False, MatrixState False matrix ) ->
            let
                vector =
                    Array.get row matrix
            in
            vector
                |> Maybe.map (\d -> Dict.map (\_ _ -> False) d)
                |> Maybe.map (\d -> Dict.update var (\_ -> Just True) d)
                |> Maybe.map (\d -> Array.set row d matrix)
                |> Maybe.withDefault matrix
                |> MatrixState False
                |> set_state model idx

        Just ( False, MatrixState True matrix ) ->
            let
                vector =
                    Array.get row matrix
            in
            vector
                |> Maybe.map (\d -> Dict.update var (\b -> Maybe.map not b) d)
                |> Maybe.map (\d -> Array.set row d matrix)
                |> Maybe.withDefault matrix
                |> MatrixState True
                |> set_state model idx

        _ ->
            model


set_state : Model -> ID -> SurveyState -> Model
set_state model idx state =
    Array.set idx ( False, state ) model


submit : Model -> ID -> Model
submit model idx =
    case Array.get idx model of
        Just ( False, state ) ->
            Array.set idx ( True, state ) model

        _ ->
            model


submitable : Model -> ID -> Bool
submitable model idx =
    case Array.get idx model of
        Just ( False, TextState str ) ->
            str /= ""

        Just ( False, VectorState _ vector ) ->
            vector
                |> Dict.values
                |> List.filter (\a -> a)
                |> List.length
                |> (\s -> s > 0)

        Just ( False, MatrixState _ matrix ) ->
            matrix
                |> Array.toList
                |> List.map Dict.values
                |> List.map (\l -> List.filter (\a -> a) l)
                |> List.all (\a -> List.length a > 0)

        _ ->
            False
