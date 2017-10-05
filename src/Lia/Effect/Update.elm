module Lia.Effect.Update exposing (Msg(..), init, next, previous, repeat, silence, update)

import Lia.Effect.Model exposing (Model, Status(..), get_comment)
import Tts.Responsive


--import Tts.Tts as Tts


type Msg
    = Init Bool
    | Next Bool
    | Previous Bool
    | Repeat Bool
    | Speak Bool
    | TTS (Result String Never)


update : Msg -> Model -> ( Model, Cmd Msg, Bool )
update msg model =
    let
        stop_talking model =
            case model.status of
                Speaking ->
                    let
                        c =
                            Tts.Responsive.cancel ()
                    in
                    ( { model | status = Silent }, Cmd.none, True )

                _ ->
                    ( model, Cmd.none, True )
    in
    case msg of
        Init silent ->
            update (Speak silent) model

        Next silent ->
            if model.visible == model.effects then
                stop_talking model
            else
                update (Speak silent) { model | visible = model.visible + 1 }

        Repeat silent ->
            update (Speak silent) model

        Previous silent ->
            if model.visible == 0 then
                stop_talking model
            else
                update (Speak silent) { model | visible = model.visible - 1 }

        Speak silent ->
            case ( get_comment model, silent ) of
                ( Just str, False ) ->
                    ( { model | status = Speaking }, Tts.Responsive.speak TTS model.narrator str, False )

                _ ->
                    ( model, Cmd.none, False )

        TTS (Result.Ok _) ->
            ( { model | status = Silent }, Cmd.none, False )

        TTS (Result.Err m) ->
            ( { model | status = Error m }, Cmd.none, False )


init : Bool -> Model -> ( Model, Cmd Msg, Bool )
init silent =
    update (Init silent)


next : Bool -> Model -> ( Model, Cmd Msg, Bool )
next silent =
    update (Next silent)


repeat : Bool -> Model -> ( Model, Cmd Msg, Bool )
repeat silent =
    update (Repeat silent)


previous : Bool -> Model -> ( Model, Cmd Msg, Bool )
previous silent =
    update (Previous silent)


silence : a -> Bool
silence b =
    Tts.Responsive.cancel ()
