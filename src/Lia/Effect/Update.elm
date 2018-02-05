module Lia.Effect.Update exposing (Msg(..), has_next, has_previous, init, next, previous, repeat, update)

import Lia.Effect.Model exposing (Model, current_comment)
import Tts.Responsive


--import Tts.Tts as Tts


type Msg
    = Init
    | Next
    | Previous
    | Repeat
    | Speak
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

        Speak ->
            case ( sound, current_comment model ) of
                ( True, Just ( comment, narrator ) ) ->
                    let
                        c =
                            Tts.Responsive.cancel ()
                    in
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


init : Msg
init =
    Init


has_next : Model -> Bool
has_next model =
    model.visible < model.effects



--next : Bool -> Model -> ( Model, Cmd Msg )


has_previous : Model -> Bool
has_previous model =
    model.visible > 0


next : Msg
next =
    Next


previous : Msg
previous =
    Previous


repeat : Msg
repeat =
    Repeat



--silence : a -> Bool
--silence b =
--    Tts.Responsive.cancel ()
