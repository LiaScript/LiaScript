module Lia.Settings.Update exposing
    ( Msg(..)
    , Toggle(..)
    , customizeEvent
    , handle
    , toggle_sound
    , update
    )

import Json.Encode as JE
import Lia.Settings.Json as Json
import Lia.Settings.Types exposing (Action(..), Mode(..), Settings)
import Lia.Utils exposing (focus)
import Port.Event exposing (Event)
import Port.TTS as TTS


type Msg
    = Toggle Toggle
    | ChangeTheme String
    | ChangeEditor String
    | ChangeLang String
    | ChangeFontSize Int
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
    | TranslateWithGoogle


update : Msg -> Settings -> ( Settings, Cmd Msg, List Event )
update msg model =
    case msg of
        Handle event ->
            case event.topic of
                "init" ->
                    event.message
                        |> load { model | initialized = True }
                        |> no_log Nothing

                "speak" ->
                    no_log Nothing
                        { model
                            | speaking =
                                TTS.decode event.message == TTS.Start
                        }

                _ ->
                    log Nothing model

        Toggle TableOfContents ->
            log Nothing
                { model
                    | table_of_contents = not model.table_of_contents
                    , action = Nothing
                }

        Toggle SupportMenu ->
            log Nothing
                { model
                    | support_menu = not model.support_menu
                    , action = Nothing
                }

        Toggle Sound ->
            let
                ( new_model, _, events ) =
                    log Nothing { model | sound = not model.sound }
            in
            ( new_model, Cmd.none, TTS.event new_model.sound :: events )

        Toggle Light ->
            log Nothing { model | light = not model.light }

        Toggle (Action action) ->
            no_log
                (case action of
                    ShowModes ->
                        Just "lia-mode-textbook"

                    ShowSettings ->
                        Just "lia-btn-light-mode"

                    _ ->
                        Nothing
                )
                { model
                    | action =
                        if action == Close then
                            Nothing

                        else if model.action /= Just action then
                            Just action

                        else
                            Nothing
                }

        SwitchMode mode ->
            case mode of
                Textbook ->
                    let
                        ( new_model, _, events ) =
                            log Nothing { model | sound = False, mode = Textbook }
                    in
                    ( new_model, Cmd.none, TTS.event new_model.sound :: events )

                _ ->
                    log Nothing { model | mode = mode }

        ChangeTheme theme ->
            log Nothing
                { model
                    | theme =
                        if theme == "custom" && model.customTheme /= Nothing then
                            theme

                        else
                            theme
                }

        ChangeEditor theme ->
            log Nothing { model | editor = theme }

        ChangeFontSize size ->
            log Nothing { model | font_size = size }

        ChangeLang lang ->
            log Nothing { model | lang = lang }

        Reset ->
            ( model, Cmd.none, [ Event "reset" -1 JE.null ] )

        ShareCourse event ->
            ( model, Cmd.none, [ event ] )

        Toggle TranslateWithGoogle ->
            ( { model | translateWithGoogle = True }
            , Cmd.none
            , [ Event "googleTranslate" -1 JE.null ]
            )

        Ignore ->
            ( model, Cmd.none, [] )


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


log : Maybe String -> Settings -> ( Settings, Cmd Msg, List Event )
log elementID settings =
    ( settings
    , maybeFocus elementID
    , [ customizeEvent settings ]
    )


customizeEvent : Settings -> Event
customizeEvent settings =
    [ settings
        |> Json.fromModel
    , if settings.theme == "custom" then
        settings.customTheme
            |> Maybe.map JE.string
            |> Maybe.withDefault JE.null

      else
        JE.null
    ]
        |> JE.list identity
        |> Event "settings" -1


no_log : Maybe String -> Settings -> ( Settings, Cmd Msg, List Event )
no_log elementID settings =
    ( settings
    , maybeFocus elementID
    , []
    )


maybeFocus : Maybe String -> Cmd Msg
maybeFocus =
    Maybe.map (focus Ignore) >> Maybe.withDefault Cmd.none
