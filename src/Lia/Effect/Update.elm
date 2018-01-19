module Lia.Effect.Update exposing (Msg(..), has_next, has_previous, init, next, previous, repeat, update)

--, Status(..), get_comment)

import Lia.Effect.Model exposing (Model)
import Tts.Responsive


--import Tts.Tts as Tts


type Msg
    = Init
    | Next
    | Previous
    | Repeat
    | Speak
    | TTS (Result String Never)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
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
        --      Init silent ->
        --          update (Speak silent) model
        Next ->
            if has_next model then
                --    stop_talking model
                ( { model | visible = model.visible + 1 }, Cmd.none )
            else
                --update (Speak silent)
                ( model, Cmd.none )

        --        Repeat silent ->
        --            update (Speak silent) model
        Previous ->
            if has_previous model then
                ( { model | visible = model.visible - 1 }, Cmd.none )
                --stop_talking model
            else
                --update (Speak silent)
                ( model, Cmd.none )

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


init : Model -> ( Model, Cmd Msg )
init =
    update Init


has_next : Model -> Bool
has_next model =
    model.visible < model.effects


next : Model -> Maybe Model
next model =
    if model.visible < model.effects then
        Just { model | visible = model.visible + 1 }
    else
        --update (Speak silent)
        Nothing


has_previous : Model -> Bool
has_previous model =
    model.visible > 0


previous : Model -> Maybe Model
previous model =
    if model.visible > 0 then
        Just { model | visible = model.visible - 1 }
    else
        --update (Speak silent)
        Nothing


repeat : Model -> ( Model, Cmd Msg )
repeat =
    update Repeat



--silence : a -> Bool
--silence b =
--    Tts.Responsive.cancel ()
