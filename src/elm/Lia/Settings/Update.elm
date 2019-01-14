module Lia.Settings.Update exposing (Button(..), Msg(..), toggle_sound, toggle_table_of_contents, update)

import Json.Decode as JD
import Json.Encode as JE
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


update : Msg -> Model -> ( Model, Maybe JE.Value )
update msg model =
    case msg of
        Toggle_TableOfContents ->
            log
                { model
                    | table_of_contents = not model.table_of_contents
                    , buttons = init_buttons
                }

        Toggle_Sound ->
            log { model | sound = not model.sound }

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


log : Model -> ( Model, Maybe JE.Value )
log model =
    ( model, Just <| model2json model )


no_log : Model -> ( Model, Maybe JE.Value )
no_log model =
    ( model, Nothing )
