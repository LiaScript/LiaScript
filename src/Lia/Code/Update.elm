module Lia.Code.Update exposing (Msg(..), update)

import Array exposing (Array)
import Lia.Code.Types exposing (Element, EvalString, Vector)
import Lia.Helper exposing (ID)
import Lia.Utils


type Msg
    = Eval ID EvalString
    | Update ID String
    | FlipMode ID
    | EvalRslt (Result { id : ID, result : String } { id : ID, result : String })
    | Load ID Int


update : Msg -> Vector -> ( Vector, Cmd Msg )
update msg model =
    case msg of
        Eval idx x ->
            case Array.get idx model of
                Just elem ->
                    update_ idx
                        model
                        (\e -> { e | editing = False, running = True })
                        (String.join
                            (elem.code |> String.split "\\" |> String.join "\\\\")
                            x
                            |> Lia.Utils.evaluateJS2 EvalRslt idx
                        )

                Nothing ->
                    ( model, Cmd.none )

        EvalRslt (Ok { id, result }) ->
            update_ id model (resulting (Ok result)) Cmd.none

        EvalRslt (Err { id, result }) ->
            update_ id model (resulting (Err result)) Cmd.none

        Update idx code_str ->
            update_ idx model (\e -> { e | code = code_str }) Cmd.none

        FlipMode idx ->
            update_ idx model (\e -> { e | editing = not e.editing }) Cmd.none

        Load idx version ->
            update_ idx model (load version) Cmd.none


update_ : ID -> Vector -> (Element -> Element) -> Cmd msg -> ( Vector, Cmd msg )
update_ idx model f cmd =
    ( case Array.get idx model of
        Just elem ->
            Array.set idx (f elem) model

        Nothing ->
            model
    , cmd
    )


resulting : Result String String -> Element -> Element
resulting result elem =
    let
        ( code, _ ) =
            elem.version
                |> Array.get elem.version_active
                |> Maybe.withDefault ( "", Ok "" )

        e =
            { elem | result = result, running = False }
    in
    if code == e.code then
        { e
            | version = Array.set e.version_active ( code, result ) e.version
        }
    else
        { e
            | version = Array.push ( e.code, result ) e.version
            , version_active = Array.length e.version
        }


load : Int -> Element -> Element
load version elem =
    if (version >= 0) && (version < Array.length elem.version) then
        let
            ( code, result ) =
                elem.version
                    |> Array.get version
                    |> Maybe.withDefault ( elem.code, Ok "" )
        in
        { elem
            | version_active = version
            , code = code
            , result = result
        }
    else
        elem
