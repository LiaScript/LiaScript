module Lia.Settings.Json exposing
    ( fromModel
    , toModel
    )

import Json.Decode as JD
import Json.Decode.Pipeline as JDP
import Json.Encode as JE
import Lia.Markdown.Code.Editor exposing (editor)
import Lia.Markdown.Inline.Multimedia exposing (audio)
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
        , ( "PreferBrowserTTS", JE.bool model.tts.preferBrowser )
        , ( "hideVideoComments", JE.bool model.hideVideoComments )
        , ( "audio"
          , JE.object
                [ ( "pitch", maybeFloat model.audio.pitch )
                , ( "rate", maybeFloat model.audio.rate )
                ]
          )
        ]


maybeFloat : String -> JE.Value
maybeFloat =
    String.toFloat >> Maybe.withDefault 1.0 >> JE.float


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


settings :
    Settings
    -> Bool
    -> Mode
    -> String
    -> Bool
    -> String
    -> Int
    -> Bool
    -> String
    -> Bool
    -> Bool
    -> Bool
    -> { pitch : String, rate : String }
    -> Settings
settings model toc mode theme light editor font_size sound lang tooltips preferBrowserTTS hideVideoComments audio =
    let
        tts =
            model.tts
    in
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
        , tts = { tts | preferBrowser = preferBrowserTTS }
        , hideVideoComments = hideVideoComments
        , audio = audio
    }


toModel : Settings -> JD.Value -> Result JD.Error Settings
toModel model =
    JD.decodeValue
        (JD.succeed
            (\record -> settings model record)
            |> JDP.required "table_of_contents" JD.bool
            |> JDP.required "mode" (JD.string |> JD.andThen toMode)
            |> JDP.required "theme" JD.string
            |> JDP.required "light" JD.bool
            |> JDP.required "editor" JD.string
            |> JDP.required "font_size" JD.int
            |> JDP.required "sound" JD.bool
            |> JDP.required "lang" JD.string
            |> JDP.optional "tooltips" JD.bool False
            |> JDP.optional "PreferBrowserTTS" JD.bool True
            |> JDP.optional "hideVideoComments" JD.bool False
            |> JDP.optional "audio"
                (JD.succeed
                    (\pitch rate -> { pitch = pitch, rate = rate })
                    |> JDP.required "pitch" (JD.float |> JD.map String.fromFloat)
                    |> JDP.required "rate" (JD.float |> JD.map String.fromFloat)
                )
                { pitch = "1", rate = "1" }
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
