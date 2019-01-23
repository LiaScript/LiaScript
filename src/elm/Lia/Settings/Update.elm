module Lia.Settings.Update exposing (Button(..), Msg(..), load, toggle_sound, toggle_table_of_contents, update)

import Json.Decode as JD
import Json.Encode as JE
import Lia.Effect.Update exposing (soundEvent)
import Lia.Event exposing (..)
import Lia.Settings.JSON exposing (..)
import Lia.Settings.Model exposing (..)


type Msg
    = Toggle_TableOfContents
    | Toggle_Sound
    | Toggle_Light
    | Toggle Button
    | ChangeTheme String
    | ChangeEditor String
    | ChangeLang String
    | ChangeFontSize Bool
    | SwitchMode


type Button
    = Settings
    | Translations
    | Informations
    | Share


update : Msg -> Model -> ( Model, List Event )
update msg model =
    case msg of
        Toggle_TableOfContents ->
            log
                { model
                    | table_of_contents = not model.table_of_contents
                    , buttons = init_buttons
                }

        Toggle_Sound ->
            let
                ( new_model, events ) =
                    log { model | sound = not model.sound }
            in
            ( new_model, soundEvent new_model.sound :: events )

        Toggle_Light ->
            log { model | light = not model.light }

        Toggle button ->
            no_log { model | buttons = toggle button model.buttons }

        SwitchMode ->
            log
                { model
                    | mode =
                        case model.mode of
                            Presentation ->
                                Slides

                            Slides ->
                                Textbook

                            Textbook ->
                                Presentation
                }

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


load : Model -> JE.Value -> Model
load model json =
    json
        |> json2model model
        |> Result.withDefault model


toggle_sound : Msg
toggle_sound =
    Toggle_Sound


toggle_table_of_contents : Msg
toggle_table_of_contents =
    Toggle_TableOfContents


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
    ( model, [ Event "settings" -1 <| model2json model ] )


no_log : Model -> ( Model, List Event )
no_log model =
    ( model, [] )
