module Lia.Effect.Update exposing (Msg(..), init, next, previous, update)

import Lia.Effect.Model exposing (Model, Status(..), get_comment)
import Responsive


--import Tts.Tts as Tts


type Msg
    = Init
    | Next
    | Previous
    | Speak
    | TTS (Result String Never)


update : Msg -> Model -> ( Model, Cmd Msg, Bool )
update msg model =
    let
        stop_talking model =
            case model.status of
                Speaking ->
                    let
                        c =
                            Responsive.cancel ()
                    in
                    ( { model | status = Silent }, Cmd.none, True )

                _ ->
                    ( model, Cmd.none, True )
    in
    case msg of
        Init ->
            update Speak model

        Next ->
            if model.visible == model.effects then
                stop_talking model
            else
                update Speak { model | visible = model.visible + 1 }

        Previous ->
            if model.visible == 0 then
                stop_talking model
            else
                update Speak { model | visible = model.visible - 1 }

        Speak ->
            case get_comment model of
                Just str ->
                    ( { model | status = Speaking }, Responsive.speak TTS model.narator str, False )

                Nothing ->
                    ( model, Cmd.none, False )

        TTS (Result.Ok _) ->
            ( { model | status = Silent }, Cmd.none, False )

        TTS (Result.Err m) ->
            ( { model | status = Error m }, Cmd.none, False )


init : Model -> ( Model, Cmd Msg, Bool )
init =
    update Init


next : Model -> ( Model, Cmd Msg, Bool )
next =
    update Next


previous : Model -> ( Model, Cmd Msg, Bool )
previous =
    update Previous
