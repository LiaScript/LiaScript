module Lia.Code.Update exposing (Msg(..), update)

import Array exposing (Array)
import Lia.Code.Types exposing (CodeVector)
import Lia.Helper exposing (ID)
import Lia.Utils


type Msg
    = Eval ID (List String)
    | Update ID String
    | FlipMode ID
    | EvalRslt (Result { id : ID, result : String } { id : ID, result : String })
    | Load ID Int


last : Array String -> String
last a =
    a
        |> Array.get (Array.length a - 1)
        |> Maybe.withDefault ""


update : Msg -> CodeVector -> ( CodeVector, Cmd Msg )
update msg model =
    case msg of
        Eval idx x ->
            case Array.get idx model of
                Just elem ->
                    let
                        exec =
                            String.join elem.code x

                        ( version, active ) =
                            if ((elem.version_active + 1) == Array.length elem.version) && (elem.code /= last elem.version) then
                                ( Array.push elem.code elem.version
                                , Array.length elem.version
                                )
                            else
                                ( elem.version, elem.version_active )
                    in
                    ( Array.set idx
                        { elem
                            | editing = False
                            , running = True
                            , version = version
                            , version_active = active
                        }
                        model
                    , Lia.Utils.evaluateJS2 EvalRslt idx exec
                    )

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

        Load idx version ->
            case Array.get idx model of
                Just elem ->
                    if (version >= 0) && (version < Array.length elem.version) then
                        ( Array.set idx
                            { elem
                                | version_active = version
                                , code =
                                    elem.version
                                        |> Array.get version
                                        |> Maybe.withDefault elem.code
                            }
                            model
                        , Cmd.none
                        )
                    else
                        ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )
