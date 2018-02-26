module Lia.Model exposing (..)

import Array exposing (Array)
import Lia.Definition.Types as Definition exposing (Definition)
import Lia.Helper exposing (ID)
import Lia.Index.Model as Index
import Lia.Types exposing (Design, Mode, Sections)
import Lia.Utils exposing (get_local, load_js, set_local)


type alias Model =
    { url : String
    , mode : Mode
    , error : Maybe String
    , sections : Sections
    , section_active : ID
    , definition : Definition
    , design : Design
    , loc : Bool
    , index_model : Index.Model
    , sound : Bool
    , show_settings : Bool
    }


init : Mode -> String -> Maybe Int -> Model
init mode url slide_number =
    let
        local_mode =
            case get_local "mode" of
                Just "Slides" ->
                    Lia.Types.Slides

                Just "Presentation" ->
                    Lia.Types.Presentation

                _ ->
                    mode
    in
    { url = url
    , mode = local_mode
    , error = Nothing
    , sections = Array.empty
    , section_active =
        case slide_number of
            Just idx ->
                if (idx - 1) > 0 then
                    idx - 1
                else
                    0

            Nothing ->
                init_section url
    , definition = Definition.default url
    , design =
        { theme = init_design_theme
        , light = init_design_light
        }
    , loc = True
    , index_model = Index.init
    , sound = init_sound
    , show_settings = False
    }


init_design_theme : String
init_design_theme =
    "theme"
        |> get_local
        |> Maybe.withDefault "default"


init_design_light : String
init_design_light =
    "theme_light"
        |> get_local
        |> Maybe.withDefault "light"


init_section : String -> Int
init_section url =
    if url == "" then
        0
    else
        url
            |> get_local
            |> Maybe.map String.toInt
            |> Maybe.andThen Result.toMaybe
            |> Maybe.withDefault 0


init_sound : Bool
init_sound =
    "sound"
        |> get_local
        |> Maybe.andThen (\b -> b /= "false" |> Just)
        |> Maybe.withDefault True
