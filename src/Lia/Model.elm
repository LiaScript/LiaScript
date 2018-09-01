module Lia.Model exposing (Model, Toogler, init, init_font_size, init_section, init_sound, init_string, load_javascript)

import Array exposing (Array)
import Lia.Definition.Types as Definition exposing (Definition)
import Lia.Helper exposing (ID)
import Lia.Index.Model as Index
import Lia.Types exposing (Design, Mode, Sections)
import Lia.Utils exposing (get_local, load, set_local)
import Translations


type alias Toogler =
    { loc : Bool
    , settings : Bool
    , informations : Bool
    , translations : Bool
    , share : Bool
    }


type alias Model =
    { url : String
    , readme : String
    , origin : String
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
    , translation : Translations.Lang
    }


init : Mode -> String -> String -> String -> Maybe Int -> Model
init mode url readme origin slide_number =
    let
        local_mode =
            case get_local "mode" of
                Just "Slides" ->
                    Lia.Types.Slides

                Just "Presentation" ->
                    Lia.Types.Presentation

                Just "Textbook" ->
                    Lia.Types.Textbook

                _ ->
                    mode
    in
    { url = url
    , readme = readme
    , origin = origin
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
        { theme = init_string "theme" "default"
        , light = init_string "theme_light" "light"
        , font_size = init_font_size
        , ace = init_string "ace" "dreamweaver"
        }
    , index_model = Index.init
    , sound = init_sound
    , show = Toogler True False False False False
    , javascript = []
    , translation = Translations.En
    }


init_string : String -> String -> String
init_string id_ default =
    id_
        |> get_local
        |> Maybe.map (String.dropLeft 1 >> String.dropRight 1)
        |> Maybe.withDefault default


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
            List.map (load "script") to_load
    in
    List.append old to_load
