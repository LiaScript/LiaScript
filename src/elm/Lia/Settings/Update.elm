module Lia.Settings.Update exposing
    ( Button(..)
    , Msg(..)
    , Toggle(..)
    , handle
    , toggle_sound
    , update
    )

import Json.Encode as JE
import Lia.Settings.Json as Json
import Lia.Settings.Types exposing (Buttons, Mode(..), Settings, initButtons)
import Port.Event exposing (Event)
import Port.TTS as TTS


type Msg
    = Toggle Toggle
    | ChangeTheme String
    | ChangeEditor String
    | ChangeLang String
    | ChangeFontSize Bool
    | SwitchMode
    | Reset
    | Handle Event
    | ShareCourse Event
    | Ignore


type Toggle
    = TableOfContents
    | Sound
    | Light
    | Button Button


type Button
    = BtnSettings
    | BtnTranslations
    | BtnInformations
    | BtnShare


update : Msg -> Settings -> ( Settings, List Event )
update msg model =
    case msg of
        Handle event ->
            no_log <|
                case event.topic of
                    "init" ->
                        event.message
                            |> load { model | initialized = True }

                    "speak" ->
                        { model
                            | speaking =
                                TTS.decode event.message == TTS.Start
                        }

                    _ ->
                        model

        Toggle TableOfContents ->
            log
                { model
                    | table_of_contents = not model.table_of_contents
                    , buttons = initButtons
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
                    let
                        ( new_model, events ) =
                            log { model | sound = True, mode = Presentation }
                    in
                    ( new_model, TTS.event new_model.sound :: events )

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

        ShareCourse event ->
            ( model, [ event ] )

        Ignore ->
            ( model, [] )


handle : Event -> Msg
handle =
    Handle


load : Settings -> JE.Value -> Settings
load model =
    Json.toModel model
        >> Result.withDefault model


toggle_sound : Msg
toggle_sound =
    Toggle Sound


toggle : Button -> Buttons -> Buttons
toggle toggle_button buttons =
    let
        new_buttons =
            initButtons
    in
    case toggle_button of
        BtnSettings ->
            { new_buttons | settings = not buttons.settings }

        BtnTranslations ->
            { new_buttons | translations = not buttons.translations }

        BtnInformations ->
            { new_buttons | informations = not buttons.informations }

        BtnShare ->
            { new_buttons | share = not buttons.share }


log : Settings -> ( Settings, List Event )
log settings =
    ( settings
    , [ settings
            |> Json.fromModel
            |> Event "settings" -1
      ]
    )


no_log : Settings -> ( Settings, List Event )
no_log model =
    ( model, [] )
