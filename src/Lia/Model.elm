module Lia.Model exposing (..)

import Array exposing (Array)
import Lia.Definition.Types as Definition exposing (Definition)
import Lia.Helper exposing (ID)
import Lia.Index.Model as Index
import Lia.Types exposing (Design, Mode, Sections)
import Lia.Utils exposing (get_local, load_js, set_local)


type alias Toogler =
    { loc : Bool, settings : Bool, informations : Bool, translations : Bool, share : Bool }


type alias Model =
    { url : String
    , readme : String
    , mode : Mode
    , error : Maybe String
    , sections : Sections
    , section_active : ID
    , definition : Definition
    , design : Design
    , index_model : Index.Model
    , sound : Bool
    , show : Toogler
    , javascript : List String
    }


init : Mode -> String -> String -> Maybe Int -> Model
init mode url readme slide_number =
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
    , readme = readme
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
        , font_size = init_font_size
        }
    , index_model = Index.init
    , sound = init_sound
    , show = Toogler True False False False False
    , javascript = []
    }


init_design_theme : String
init_design_theme =
    "theme"
        |> get_local
        |> Maybe.map (String.dropLeft 1 >> String.dropRight 1)
        |> Maybe.withDefault "default"


init_design_light : String
init_design_light =
    "theme_light"
        |> get_local
        |> Maybe.map (String.dropLeft 1 >> String.dropRight 1)
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


init_font_size : Int
init_font_size =
    "font_size"
        |> get_local
        |> Maybe.map String.toInt
        |> Maybe.andThen Result.toMaybe
        |> Maybe.withDefault 100


load_javascript : List String -> List String -> List String
load_javascript old new =
    let
        member x =
            not (List.member x old)

        to_load =
            List.filter member new

        x =
            List.map load_js to_load
    in
    List.append old to_load
