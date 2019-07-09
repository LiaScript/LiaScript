module Lia.Settings.Update exposing
    ( Button(..)
    , Msg(..)
    , Toggle(..)
    , handle
    , load
    , toggle_sound
    , toggle_table_of_contents
    , update
    )

import Json.Encode as JE
import Lia.Event.Base exposing (Event)
import Lia.Event.TTS as TTS
import Lia.Settings.Json as Json
import Lia.Settings.Model exposing (Buttons, Mode(..), Model, init_buttons)


type Msg
    = Toggle Toggle
    | ChangeTheme String
    | ChangeEditor String
    | ChangeLang String
    | ChangeFontSize Bool
    | SwitchMode
    | Reset
    | Handle Event


type Toggle
    = TableOfContents
    | Sound
    | Light
    | Button Button


type Button
    = Settings
    | Translations
    | Informations
    | Share


update : Msg -> Model -> ( Model, List Event )
update msg model =
    case msg of
        Handle event ->
            no_log <|
                case event.topic of
                    "init" ->
                        event.message
                            |> load { model | initialized = True }

                    "speak" ->
                        event.message
                            |> TTS.decode
                            |> tts model

                    _ ->
                        model

        Toggle TableOfContents ->
            log
                { model
                    | table_of_contents = not model.table_of_contents
                    , buttons = init_buttons
                }

        Toggle Sound ->
            let
                ( new_model, events ) =
                    log { model | sound = not model.sound }
            in
            ( new_model, TTS.event new_model.sound :: events )

        Toggle Light ->
            log { model | light = not model.light }

        Toggle (Button button) ->
            no_log { model | buttons = toggle button model.buttons }

        SwitchMode ->
            case model.mode of
                Presentation ->
                    log { model | mode = Slides }

                Slides ->
                    let
                        ( new_model, events ) =
                            log { model | sound = False, mode = Textbook }
                    in
                    ( new_model, TTS.event new_model.sound :: events )

                Textbook ->
                    log { model | mode = Presentation }

        ChangeTheme theme ->
            log { model | theme = theme }

        ChangeEditor theme ->
            log { model | editor = theme }

        ChangeFontSize inc ->
            log
                { model
                    | font_size =
                        if inc then
                            -- positive value
                            model.font_size + 10

                        else if model.font_size <= 10 then
                            -- check if the new value is already too small
                            model.font_size

                        else
                            -- decrease
                            model.font_size - 10
                }

        ChangeLang lang ->
            log { model | lang = lang }

        Reset ->
            ( model, [ Event "reset" -1 JE.null ] )


tts : Model -> TTS.Msg -> Model
tts model msg =
    case msg of
        TTS.Start ->
            { model | speaking = True }

        TTS.Repeat ->
            { model | speaking = True }

        _ ->
            { model | speaking = False }


handle : Event -> Msg
handle =
    Handle


load : Model -> JE.Value -> Model
load model json =
    json
        |> Json.toModel model
        |> Result.withDefault model


toggle_sound : Msg
toggle_sound =
    Toggle Sound


toggle_table_of_contents : Msg
toggle_table_of_contents =
    Toggle TableOfContents


toggle : Button -> Buttons -> Buttons
toggle toggle_button buttons =
    let
        new_buttons =
            init_buttons
    in
    case toggle_button of
        Settings ->
            { new_buttons | settings = not buttons.settings }

        Translations ->
            { new_buttons | translations = not buttons.translations }

        Informations ->
            { new_buttons | informations = not buttons.informations }

        Share ->
            { new_buttons | share = not buttons.share }


log : Model -> ( Model, List Event )
log model =
    ( model, [ Event "settings" -1 <| Json.fromModel model ] )


no_log : Model -> ( Model, List Event )
no_log model =
    ( model, [] )
