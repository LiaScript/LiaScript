module Lia.Effect.Update exposing (Msg(..), has_next, has_previous, init, next, previous, update)

import Lia.Effect.Model exposing (Model, current_comment)
import Tts.Responsive


--import Tts.Tts as Tts


type Msg
    = Init
    | Next
    | Previous
    | Speak
    | Silence
    | TTS (Result String Never)


update : Msg -> Bool -> Model -> ( Model, Cmd Msg )
update msg sound model =
    --    let
    --        stop_talking model =
    --            case model.status of
    --                Speaking ->
    --                    let
    --                        c =
    --                            Tts.Responsive.cancel ()
    --                    in
    --                    ( { model | status = Silent }, Cmd.none, True )
    --
    --                _ ->
    --                    ( model, Cmd.none, True )
    --    in
    case msg of
        Init ->
            update Speak sound model

        Next ->
            if has_next model then
                --    stop_talking model
                update Speak sound { model | visible = model.visible + 1 }
            else
                --update (Speak silent)
                ( model, Cmd.none )

        --        Repeat silent ->
        --            update (Speak silent) model
        Previous ->
            if has_previous model then
                update Speak sound { model | visible = model.visible - 1 }
                --stop_talking model
            else
                --update (Speak silent)
                ( model, Cmd.none )

        Silence ->
            let
                c =
                    Tts.Responsive.cancel ()
            in
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

        --    else
        --        ( model, Cmd.none )
        --        Speak ->
        --                case Dict.get model.visible model.comments of
        --                  Just str ->
        --                      ( model, Tts.Responsive.speak TTS model.narrator str )
        --
        --                _ ->
        --                    ( model, Cmd.none, False )
        _ ->
            ( model, Cmd.none )



--        Speak silent ->
--            case ( get_comment model, silent ) of
--                ( Just str, False ) ->
--                    ( { model | status = Speaking }, Tts.Responsive.speak TTS model.narrator str, False )
--
--                _ ->
--                    ( model, Cmd.none, False )
--
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


silence : Msg
silence =
    Silence



--silence : a -> Bool
--silence b =
--    Tts.Responsive.cancel ()
