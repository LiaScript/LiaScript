module Lia.Settings.Update exposing
    ( Msg(..)
    , Toggle(..)
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
import Port.Event as Event exposing (Event)
import Port.Share
import Port.TTS as TTS
import Return exposing (Return)


type Msg
    = Toggle Toggle
    | ChangeTheme String
    | ChangeEditor String
    | ChangeLang String
    | ChangeFontSize Int
    | SwitchMode Mode
    | Reset
    | Handle Event
    | ShareCourse String
    | Ignore


type Toggle
    = TableOfContents
    | Sound
    | Light
    | Action Action
    | SupportMenu
    | TranslateWithGoogle
    | Tooltips


update :
    Maybe { title : String, comment : Inlines }
    -> Msg
    -> Settings
    -> Return Settings Msg sub
update main msg model =
    case msg of
        Handle event ->
            case Event.topic_ event of
                Just "init" ->
                    event
                        |> Event.message
                        |> load { model | initialized = True }
                        |> no_log Nothing

                Just "speak" ->
                    no_log Nothing
                        { model
                            | speaking =
                                event
                                    |> Event.message
                                    |> TTS.decode
                                    |> (==) TTS.Start
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
                return =
                    log Nothing { model | sound = not model.sound }
            in
            return
                |> Return.batchEvent (TTS.event return.value.sound)

        Toggle Light ->
            log Nothing { model | light = not model.light }

        Toggle Tooltips ->
            log Nothing { model | tooltips = not model.tooltips }

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
                        return =
                            log Nothing { model | sound = False, mode = Textbook }
                    in
                    return
                        |> Return.batchEvent (TTS.event return.value.sound)

                _ ->
                    log Nothing { model | mode = mode }

        ChangeTheme theme ->
            log Nothing
                { model
                    | theme =
                        -- if theme == "custom" && model.customTheme /= Nothing then
                        --    theme
                        --else
                        theme
                }

        ChangeEditor theme ->
            log Nothing { model | editor = theme }

        ChangeFontSize size ->
            log Nothing { model | font_size = size }

        ChangeLang lang ->
            log Nothing { model | lang = lang }

        Reset ->
            model
                |> Return.val
                |> Return.batchEvent (Event.empty "reset")

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
                        |> Port.Share.share
                    )

        Toggle TranslateWithGoogle ->
            { model | translateWithGoogle = True }
                |> Return.val
                |> Return.batchEvent (Event.empty "googleTranslate")

        Ignore ->
            Return.val model


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
        |> Event.init "settings"


no_log : Maybe String -> Settings -> Return Settings Msg sub
no_log elementID =
    Return.val >> Return.cmd (maybeFocus elementID)


maybeFocus : Maybe String -> Cmd Msg
maybeFocus =
    Maybe.map (focus Ignore) >> Maybe.withDefault Cmd.none
