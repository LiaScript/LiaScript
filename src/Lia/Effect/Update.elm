module Lia.Effect.Update exposing (Msg(..), has_next, has_previous, init, next, previous, update)

import Lia.Effect.Model exposing (Model, current_comment)
import Tts.Responsive


--import Tts.Tts as Tts


type Msg
    = Init
    | Next
    | Previous
    | Speak
    | TTS (Result String Never)


update : Msg -> Bool -> Model -> ( Model, Cmd Msg )
update msg sound model =
    case msg of
        Init ->
            update Speak sound model

        Next ->
            if has_next model then
                update Speak sound { model | visible = model.visible + 1 }
            else
                ( model, Cmd.none )

        Previous ->
            if has_previous model then
                update Speak sound { model | visible = model.visible - 1 }
            else
                ( model, Cmd.none )

        Speak ->
            let
                c =
                    Tts.Responsive.cancel ()
            in
            case ( sound, current_comment model ) of
                ( True, Just ( comment, narrator ) ) ->
                    ( model, Tts.Responsive.speak TTS narrator comment )

                _ ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )



--        TTS (Result.Ok _) ->
--            ( { model | status = Silent }, Cmd.none, False )
--
--        TTS (Result.Err m) ->
--            ( { model | status = Error m }, Cmd.none, False )


has_next : Model -> Bool
has_next model =
    model.visible < model.effects


has_previous : Model -> Bool
has_previous model =
    model.visible > 0


init : Msg
init =
    Init


next : Msg
next =
    Next


previous : Msg
previous =
    Previous
