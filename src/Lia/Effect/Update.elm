module Lia.Effect.Update exposing (Msg(..), next, previous, update)

import Lia.Effect.Model exposing (Model, Status(..), get_comment)
import Tts.Tts as Tts


type Msg
    = Next
    | Previous
    | Speak
    | TTS (Result String Never)


update : Msg -> Model -> ( Model, Cmd Msg, Bool )
update msg model =
    case msg of
        Next ->
            if model.visible == model.effects then
                ( model, Cmd.none, True )
            else
                update Speak { model | visible = model.visible + 1 }

        --( { model | visible = model.visible + 1 }, Cmd.none, False )
        Previous ->
            if model.visible == 0 then
                ( model, Cmd.none, True )
            else
                update Speak { model | visible = model.visible - 1 }

        --( { model | visible = model.visible - 1 }, Cmd.none, False )
        Speak ->
            case get_comment model of
                Just str ->
                    ( { model | status = Speaking }, Tts.speak TTS (Just "sabrina") "en_US" str, False )

                Nothing ->
                    ( model, Cmd.none, False )

        TTS (Result.Ok _) ->
            ( { model | status = Silent }, Cmd.none, False )

        TTS (Result.Err m) ->
            ( { model | status = Error m }, Cmd.none, False )


next : Model -> ( Model, Cmd Msg, Bool )
next =
    update Next


previous : Model -> ( Model, Cmd Msg, Bool )
previous =
    update Previous
