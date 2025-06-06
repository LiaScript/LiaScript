module Lia.Settings.Update exposing
    ( Msg(..)
    , Toggle(..)
    , closeSync
    , customizeEvent
    , handle
    , toggle_sound
    , update
    , updatedChatMessages
    )

import Json.Encode as JE
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Settings.Json as Json
import Lia.Settings.Types exposing (Action(..), Audio(..), Mode(..), Settings)
import Lia.Utils exposing (focus, scheduleFocus)
import Return exposing (Return)
import Service.Database
import Service.Event as Event exposing (Event)
import Service.Share
import Service.Slide
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
    | FocusLoss (Maybe Action)
    | Change Audio


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
    | Navigation
    | VideoComments
    | Fullscreen


update :
    Maybe { title : String, comment : Inlines, effectID : Maybe Int, logo : Maybe String }
    -> Msg
    -> Settings
    -> Return Settings Msg sub
update main msg model =
    case msg of
        Handle event ->
            case Event.destructure event of
                ( Nothing, _, ( "init", settings ) ) ->
                    let
                        newSettings =
                            settings
                                |> load { model | initialized = True }
                    in
                    newSettings
                        |> no_log Nothing
                        |> Return.batchEvent (Service.TTS.preferBrowser newSettings.tts.preferBrowser)

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

        Toggle Fullscreen ->
            no_log Nothing { model | fullscreen = not model.fullscreen }
                |> Return.batchEvent Service.Slide.fullscreen

        Toggle Tooltips ->
            log Nothing { model | tooltips = not model.tooltips }

        Toggle Sync ->
            no_log Nothing { model | sync = Maybe.map not model.sync }
                |> Return.batchCmd
                    (if model.sync == Just False then
                        [ scheduleFocus Nothing Ignore "lia-modal-focus" ]

                     else
                        []
                    )

        Toggle QRCode ->
            no_log Nothing { model | showQRCode = not model.showQRCode }

        Toggle VideoComments ->
            log Nothing { model | hideVideoComments = not model.hideVideoComments }

        Toggle Chat ->
            let
                chat =
                    model.chat
            in
            { model
                | support_menu = False
                , chat = { chat | show = not chat.show, updates = not chat.show }
            }
                |> no_log Nothing
                |> Return.batchEvent
                    (if chat.show then
                        Event.none

                     else
                        Service.Slide.scrollDown "lia-chat-messages" 350
                    )

        Toggle (Action action) ->
            no_log
                (case action of
                    ShowModes ->
                        Just "lia-mode-textbook"

                    ShowSettings ->
                        Just "lia-btn-light-mode"

                    ShowShare ->
                        Just "lia-button-qr-code"

                    ShowTranslations ->
                        case model.translateWithGoogle of
                            Just False ->
                                Just "lia-checkbox-google_translate"

                            Just True ->
                                Just "google-te-combo"

                            _ ->
                                Nothing

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

        Change audio_setting ->
            let
                audio =
                    model.audio
            in
            log Nothing
                { model
                    | audio =
                        case audio_setting of
                            Pitch pitch ->
                                { audio | pitch = pitch }

                            Rate value ->
                                { audio | rate = value }
                }

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
                     , image =
                        main
                            |> Maybe.andThen .logo
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
                |> log Nothing
                |> Return.batchEvent (Service.TTS.preferBrowser newPreference)

        Toggle Navigation ->
            { model | navigation = not model.navigation }
                |> log Nothing

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

        FocusLoss _ ->
            update main (Toggle (Action Close)) model

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


updatedChatMessages : Settings -> Settings
updatedChatMessages settings =
    if settings.chat.show then
        settings

    else
        let
            chat =
                settings.chat
        in
        { settings | chat = { chat | updates = True } }
