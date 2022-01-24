module Lia.Settings.Json exposing
    ( fromModel
    , toModel
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Settings.Types exposing (Mode(..), Settings)


fromModel : Settings -> JE.Value
fromModel model =
    JE.object
        [ ( "table_of_contents", JE.bool model.table_of_contents )
        , ( "mode", fromMode model.mode )
        , ( "theme", JE.string model.theme )
        , ( "light", JE.bool model.light )
        , ( "editor", JE.string model.editor )
        , ( "font_size", JE.int model.font_size )
        , ( "sound", JE.bool model.sound )
        , ( "lang", JE.string model.lang )
        , ( "tooltips", JE.bool model.tooltips )
        ]


fromMode : Mode -> JE.Value
fromMode mode =
    JE.string <|
        case mode of
            Textbook ->
                "Textbook"

            Presentation ->
                "Presentation"

            Slides ->
                "Slides"


settings : Settings -> Bool -> Mode -> String -> Bool -> String -> Int -> Bool -> String -> Bool -> Settings
settings model toc mode theme light editor font_size sound lang tooltips =
    { model
        | table_of_contents = toc
        , mode = mode
        , theme = theme
        , light = light
        , editor = editor
        , font_size = font_size
        , sound = sound
        , lang = lang
        , tooltips = tooltips
    }


toModel : Settings -> JD.Value -> Result JD.Error Settings
toModel model =
    JD.decodeValue
        (JD.map8 (settings model)
            (JD.field "table_of_contents" JD.bool)
            (JD.field "mode" JD.string |> JD.andThen toMode)
            (JD.field "theme" JD.string)
            (JD.field "light" JD.bool)
            (JD.field "editor" JD.string)
            (JD.field "font_size" JD.int)
            (JD.field "sound" JD.bool)
            (JD.field "lang" JD.string)
            -- these tooltips have been integrated later, that is
            -- why they might not be stored within the settings
            -- and treated differently
            |> JD.map2 (|>)
                (JD.maybe (JD.field "tooltips" JD.bool)
                    |> JD.map (Maybe.withDefault False)
                )
        )


toMode : String -> JD.Decoder Mode
toMode str =
    case str of
        "Textbook" ->
            JD.succeed Textbook

        "Presentation" ->
            JD.succeed Presentation

        "Slides" ->
            JD.succeed Slides

        _ ->
            JD.fail "unknown presentation mode"
