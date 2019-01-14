module Lia.Settings.JSON exposing (json2model, model2json)

import Json.Decode as JD
import Json.Encode as JE
import Lia.Settings.Model exposing (Mode(..), Model)


model2json : Model -> JE.Value
model2json model =
    JE.object
        [ ( "table_of_contents", JE.bool model.table_of_contents )
        , ( "mode", mode2json model.mode )
        , ( "theme", JE.string model.theme )
        , ( "light", JE.bool model.light )
        , ( "editor", JE.string model.editor )
        , ( "font_size", JE.int model.font_size )
        , ( "sound", JE.bool model.sound )
        , ( "lang", JE.string model.lang )
        ]


mode2json : Mode -> JE.Value
mode2json mode =
    JE.string <|
        case mode of
            Textbook ->
                "Textbook"

            Presentation ->
                "Presentation"

            Slides ->
                "Slides"


settings : Model -> Bool -> Mode -> String -> Bool -> String -> Int -> Bool -> String -> Model
settings model toc mode theme light editor font_size sound lang =
    { model
        | table_of_contents = toc
        , mode = mode
        , theme = theme
        , light = light
        , editor = editor
        , font_size = font_size
        , sound = sound
        , lang = lang
    }


json2model : Model -> JD.Value -> Result JD.Error Model
json2model model json =
    JD.decodeValue
        (JD.map8 (settings model)
            (JD.field "table_of_contents" JD.bool)
            (JD.field "mode" JD.string |> JD.andThen string2mode)
            (JD.field "theme" JD.string)
            (JD.field "light" JD.bool)
            (JD.field "editor" JD.string)
            (JD.field "font_size" JD.int)
            (JD.field "sound" JD.bool)
            (JD.field "lang" JD.string)
        )
        json


string2mode : String -> JD.Decoder Mode
string2mode str =
    case str of
        "Textbook" ->
            JD.succeed Textbook

        "Presentation" ->
            JD.succeed Presentation

        "Slides" ->
            JD.succeed Slides

        _ ->
            JD.fail "unknown presentation mode"
