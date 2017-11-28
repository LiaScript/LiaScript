module Lia.Code.Update exposing (Msg(..), update)

import Array exposing (Array)
import Lia.Code.Model exposing (Model)
import Lia.Helper as Array2D
import Lia.Utils


type Msg
    = Eval Array2D.ID2 (List String)
    | Update Array2D.ID2 String
    | FlipMode Array2D.ID2
    | EvalRslt (Result { id : Array2D.ID2, result : String } { id : Array2D.ID2, result : String })
    | Load Array2D.ID2 Int


last : Array String -> String
last a =
    a
        |> Array.get (Array.length a - 1)
        |> Maybe.withDefault ""


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Eval idx x ->
            case Array2D.get idx model of
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
                    ( Array2D.set idx
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
            case Array2D.get json.id model of
                Just elem ->
                    ( Array2D.set json.id { elem | result = Ok json.result, running = False } model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        EvalRslt (Err json) ->
            case Array2D.get json.id model of
                Just elem ->
                    ( Array2D.set json.id { elem | result = Err json.result, running = False } model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        Update idx code_str ->
            case Array2D.get idx model of
                Just elem ->
                    ( Array2D.set idx { elem | code = code_str } model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        FlipMode idx ->
            case Array2D.get idx model of
                Just elem ->
                    ( Array2D.set idx { elem | editing = not elem.editing } model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        Load idx version ->
            case Array2D.get idx model of
                Just elem ->
                    if (version >= 0) && (version < Array.length elem.version) then
                        ( Array2D.set idx
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
