module Lia.Settings.Update exposing
    ( Msg(..)
    , Toggle(..)
    , handle
    , toggle_sound
    , update
    )

import Json.Encode as JE
import Lia.Settings.Json as Json
import Lia.Settings.Types exposing (Action(..), Mode(..), Settings)
import Port.Event exposing (Event)
import Port.TTS as TTS


type Msg
    = Toggle Toggle
    | ChangeTheme String
    | ChangeEditor String
    | ChangeLang String
    | ChangeFontSize Bool
    | SwitchMode Mode
    | Reset
    | Handle Event
    | ShareCourse Event
    | Ignore


type Toggle
    = TableOfContents
    | Sound
    | Light
    | Action Action
    | SupportMenu


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
                    , action = Nothing
                }

        Toggle SupportMenu ->
            no_log
                { model
                    | support_menu = not model.support_menu
                }

        Toggle Sound ->
            let
                ( new_model, events ) =
                    log { model | sound = not model.sound }
            in
            ( new_model, TTS.event new_model.sound :: events )

        Toggle Light ->
            log { model | light = not model.light }

        Toggle (Action action) ->
            no_log
                { model
                    | action =
                        if model.action /= Just action then
                            Just action

                        else
                            Nothing
                }

        SwitchMode mode ->
            case mode of
                Textbook ->
                    let
                        ( new_model, events ) =
                            log { model | sound = False, mode = Textbook }
                    in
                    ( new_model, TTS.event new_model.sound :: events )

                _ ->
                    log { model | mode = mode }

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
