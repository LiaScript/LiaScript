module Lia.Code.Update exposing (Msg(..), update)

import Array
import Lia.Code.Model exposing (Model)
import Lia.Utils


type Msg
    = Eval Int (List String)
    | Update Int String
    | FlipMode Int
    | EvalRslt (Result { id : Int, result : String } { id : Int, result : String })


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Eval idx x ->
            case Array.get idx model of
                Just elem ->
                    let
                        exec =
                            String.join elem.code x
                    in
                    ( Array.set idx { elem | editing = False, running = True } model, Lia.Utils.evaluateJS2 EvalRslt idx exec )

                Nothing ->
                    ( model, Cmd.none )

        EvalRslt (Ok json) ->
            case Array.get json.id model of
                Just elem ->
                    ( Array.set json.id { elem | result = Ok json.result, running = False } model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        EvalRslt (Err json) ->
            case Array.get json.id model of
                Just elem ->
                    ( Array.set json.id { elem | result = Err json.result, running = False } model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        Update idx code_str ->
            case Array.get idx model of
                Just elem ->
                    ( Array.set idx { elem | code = code_str } model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        FlipMode idx ->
            case Array.get idx model of
                Just elem ->
                    ( Array.set idx { elem | editing = not elem.editing } model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )
