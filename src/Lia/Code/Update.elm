module Lia.Code.Update exposing (Msg(..), update)

import Array exposing (Array)
import Dict
import Lia.Code.Model exposing (Model)
import Lia.Utils


type Msg
    = Eval String (List String)
    | Update String String
    | FlipMode String
    | EvalRslt (Result { id : String, result : String } { id : String, result : String })


last : Array String -> String
last a =
    a
        |> Array.get (Array.length a - 1)
        |> Maybe.withDefault ""


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Eval idx x ->
            case Dict.get idx model of
                Just elem ->
                    let
                        exec =
                            String.join elem.code x
                    in
                    ( Dict.insert idx
                        { elem
                            | editing = False
                            , running = True
                            , history =
                                if elem.code /= last elem.history then
                                    Array.push elem.code elem.history
                                else
                                    elem.history
                        }
                        model
                    , Lia.Utils.evaluateJS2 EvalRslt idx exec
                    )

                Nothing ->
                    ( model, Cmd.none )

        EvalRslt (Ok json) ->
            case Dict.get json.id model of
                Just elem ->
                    ( Dict.insert json.id { elem | result = Ok json.result, running = False } model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        EvalRslt (Err json) ->
            case Dict.get json.id model of
                Just elem ->
                    ( Dict.insert json.id { elem | result = Err json.result, running = False } model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        Update idx code_str ->
            case Dict.get idx model of
                Just elem ->
                    ( Dict.insert idx { elem | code = code_str } model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        FlipMode idx ->
            case Dict.get idx model of
                Just elem ->
                    ( Dict.insert idx { elem | editing = not elem.editing } model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )
