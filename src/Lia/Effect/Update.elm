module Lia.Effect.Update exposing (Msg(..), next, previous, update)

import Lia.Effect.Model exposing (Model)
import Tts.Tts exposing (speak)


type Msg
    = Next
    | Previous
    | Speak String
    | TTS (Result String Never)


update : Msg -> Model -> ( Model, Cmd Msg, Bool )
update msg model =
    case msg of
        Next ->
            if model.visible == model.effects then
                ( model, Cmd.none, True )
            else
                update (Speak "Loading next effect") { model | visible = model.visible + 1 }

        --( { model | visible = model.visible + 1 }, Cmd.none, False )
        Previous ->
            if model.visible == 0 then
                ( model, Cmd.none, True )
            else
                update (Speak "Going back to previous one")
                    { model | visible = model.visible - 1 }

        --( { model | visible = model.visible - 1 }, Cmd.none, False )
        Speak text ->
            ( model, speak TTS Nothing "en_US" text, False )

        TTS (Result.Ok _) ->
            ( model, Cmd.none, False )

        TTS (Result.Err m) ->
            ( model, Cmd.none, False )


next : Model -> ( Model, Cmd Msg, Bool )
next =
    update Next


previous : Model -> ( Model, Cmd Msg, Bool )
previous =
    update Previous
