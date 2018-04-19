port module Lia.Effect.Update exposing (Msg(..), has_next, has_previous, init, next, previous, update)

import Lia.Effect.Model exposing (Map, Model, current_comment, get_all_javascript, get_javascript)
import Lia.Utils
import Tts.Responsive


--import Tts.Tts as Tts


port speak : ( String, String ) -> Cmd msg


type Msg
    = Init Bool
    | Next
    | Previous
    | Speak
    | TTS (Result String Never)
    | NoOp


update : Msg -> Bool -> Model -> ( Model, Cmd Msg )
update msg sound model =
    case msg of
        Init run_all_javascript ->
            let
                x =
                    speak ( "sssss", "fuck...." )
            in
            model
                |> execute run_all_javascript 1300
                |> update Speak sound

        Next ->
            if has_next model then
                { model | visible = model.visible + 1 }
                    |> execute False 100
                    |> update Speak sound
            else
                ( model, Cmd.none )

        Previous ->
            if has_previous model then
                { model | visible = model.visible - 1 }
                    |> execute False 100
                    |> update Speak sound
            else
                ( model, Cmd.none )

        Speak ->
            let
                c =
                    Tts.Responsive.cancel ()

                d =
                    Lia.Utils.scrollIntoView "focused"
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


execute : Bool -> Int -> Model -> Model
execute run_all delay model =
    let
        javascript =
            if run_all then
                get_all_javascript model
            else
                get_javascript model

        c =
            List.map (Lia.Utils.execute delay) javascript
    in
    model


has_next : Model -> Bool
has_next model =
    model.visible < model.effects


has_previous : Model -> Bool
has_previous model =
    model.visible > 0


init : Bool -> Msg
init run_all_javascript =
    Init run_all_javascript


next : Msg
next =
    Next


previous : Msg
previous =
    Previous
