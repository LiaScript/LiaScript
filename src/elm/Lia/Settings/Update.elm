module Lia.Settings.Update exposing
    ( Msg(..)
    , Toggle(..)
    , closeSync
    , customizeEvent
    , handle
    , toggle_sound
    , update
    )

import Json.Encode as JE
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Settings.Json as Json
import Lia.Settings.Types exposing (Action(..), Mode(..), Settings)
import Lia.Utils exposing (focus)
import Return exposing (Return)
import Service.Database
import Service.Event as Event exposing (Event)
import Service.Share
import Service.TTS
import Service.Translate


type Msg
    = Toggle Toggle
    | ChangeTheme String
    | ChangeEditor String
    | ChangeLang String
    | ChangeFontSize Int
    | SwitchMode Mode
    | Handle Event
    | ShareCourse String
    | Ignore


type Toggle
    = TableOfContents
    | Sound
    | Light
    | QRCode
    | Sync
    | Action Action
    | SupportMenu
    | Chat
    | TranslateWithGoogle
    | Tooltips
    | PreferBrowserTTS


update :
    Maybe { title : String, comment : Inlines, effectID : Maybe Int }
    -> Msg
    -> Settings
    -> Return Settings Msg sub
update main msg model =
    case msg of
        Handle event ->
            case Event.destructure event of
                ( Nothing, _, ( "init", settings ) ) ->
                    settings
                        |> load { model | initialized = True }
                        |> no_log Nothing

                _ ->
                    case event.service of
                        "tts" ->
                            no_log Nothing <|
                                case Service.TTS.decode event of
                                    Service.TTS.Start ->
                                        { model | speaking = True }

                                    Service.TTS.Stop ->
                                        { model | speaking = False }

                                    Service.TTS.BrowserTTS support ->
                                        let
                                            tts =
                                                model.tts
                                        in
                                        { model | tts = { tts | isBrowserSupported = support } }

                                    Service.TTS.ResponsiveVoiceTTS support ->
                                        let
                                            tts =
                                                model.tts
                                        in
                                        { model | tts = { tts | isResponsiveVoiceSupported = support } }

                                    _ ->
                                        model

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
            { model | sound = not model.sound }
                |> log Nothing
                |> Return.batchEvent
                    (Event.push "settings" <|
                        if model.sound then
                            Service.TTS.cancel

                        else
                            main
                                |> Maybe.andThen .effectID
                                |> Maybe.map Service.TTS.readFrom
                                |> Maybe.withDefault Event.none
                    )

        Toggle Light ->
            log Nothing { model | light = not model.light }

        Toggle Tooltips ->
            log Nothing { model | tooltips = not model.tooltips }

        Toggle Sync ->
            no_log Nothing { model | sync = Maybe.map not model.sync }

        Toggle QRCode ->
            no_log Nothing { model | showQRCode = not model.showQRCode }

        Toggle Chat ->
            no_log Nothing { model | showChat = not model.showChat }

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
                    { model | sound = False, mode = Textbook }
                        |> log Nothing
                        |> Return.batchEvent Service.TTS.cancel

                _ ->
                    log Nothing { model | mode = mode }

        ChangeTheme theme ->
            log Nothing
                { model | theme = theme }

        ChangeEditor theme ->
            log Nothing { model | editor = theme }

        ChangeFontSize size ->
            log Nothing { model | font_size = size }

        ChangeLang lang ->
            log Nothing { model | lang = lang }

        ShareCourse url ->
            model
                |> Return.val
                |> Return.batchEvent
                    ({ title =
                        main
                            |> Maybe.map .title
                            |> Maybe.withDefault ""
                     , text =
                        main
                            |> Maybe.map (.comment >> stringify)
                            |> Maybe.withDefault ""
                     , url = url
                     }
                        |> Service.Share.link
                    )

        Toggle PreferBrowserTTS ->
            let
                tts =
                    model.tts

                newPreference =
                    not tts.preferBrowser
            in
            { model | tts = { tts | preferBrowser = newPreference } }
                |> Return.val
                |> Return.batchEvent (Service.TTS.preferBrowser newPreference)

        Toggle TranslateWithGoogle ->
            { model
                | translateWithGoogle =
                    case model.translateWithGoogle of
                        Just _ ->
                            Just True

                        _ ->
                            Nothing
            }
                |> Return.val
                |> Return.batchEvent Service.Translate.google

        Ignore ->
            Return.val model


closeSync : Settings -> Settings
closeSync model =
    { model
        | sync =
            case model.sync of
                Just _ ->
                    Just False

                _ ->
                    Nothing
    }


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


log : Maybe String -> Settings -> Return Settings Msg sub
log elementID settings =
    settings
        |> Return.val
        |> Return.cmd (maybeFocus elementID)
        |> Return.batchEvent (customizeEvent settings)


customizeEvent : Settings -> Event
customizeEvent settings =
    settings
        |> Json.fromModel
        |> Service.Database.settings
            (if settings.theme == "custom" then
                settings.customTheme

             else
                Nothing
            )


no_log : Maybe String -> Settings -> Return Settings Msg sub
no_log elementID =
    Return.val >> Return.cmd (maybeFocus elementID)


maybeFocus : Maybe String -> Cmd Msg
maybeFocus =
    Maybe.map (focus Ignore) >> Maybe.withDefault Cmd.none
