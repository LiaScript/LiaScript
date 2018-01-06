module Lia.Code.Update exposing (Msg(..), update)

import Array exposing (Array)
import Lia.Code.Types exposing (Element, Vector)
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


update : Msg -> Vector -> ( Vector, Cmd Msg )
update msg model =
    case msg of
        Eval idx x ->
            case Array.get idx model of
                Just elem ->
                    let
                        exec =
                            String.join elem.code x

                        ( version, active ) =
                            if elem.code /= last elem.version then
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

        EvalRslt (Ok { id, result }) ->
            update_ id model (\e -> { e | result = Ok result, running = False })

        EvalRslt (Err { id, result }) ->
            update_ id model (\e -> { e | result = Err result, running = False })

        Update idx code_str ->
            update_ idx model (\e -> { e | code = code_str })

        FlipMode idx ->
            update_ idx model (\e -> { e | editing = not e.editing })

        Load idx version ->
            update_ idx model (load version)


update_ : ID -> Vector -> (Element -> Element) -> ( Vector, Cmd msg )
update_ idx model f =
    ( case Array.get idx model of
        Just elem ->
            Array.set idx (f elem) model

        Nothing ->
            model
    , Cmd.none
    )


load : Int -> Element -> Element
load version elem =
    if (version >= 0) && (version < Array.length elem.version) then
        { elem
            | version_active = version
            , code =
                elem.version
                    |> Array.get version
                    |> Maybe.withDefault elem.code
        }
    else
        elem
