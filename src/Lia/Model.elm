module Lia.Model exposing (..)

import Array exposing (Array)
import Lia.Code.Model as Code
import Lia.Definition.Types as Definition exposing (Definition)
import Lia.Effect.Model as Effect
import Lia.Index.Model as Index
import Lia.Quiz.Model as Quiz
import Lia.Survey.Model as Survey
import Lia.Types exposing (Design, ID, Mode, Sections)
import Lia.Utils exposing (get_local, load_js, set_local)


type alias Model =
    { uid : Maybe String
    , mode : Mode
    , sections : Sections
    , section_active : ID
    , definition : Definition
    , design : Design
    , loc : Bool
    , index_model : Index.Model

    --    , show_contents : Bool
    --    , quiz_model : Lia.Quiz.Model.Model
    --    , code_model : Lia.Code.Model.Model
    --    , effect_model : Lia.Effect.Model.Model
    --    , index_model : Lia.Index.Model.Model
    --    , survey_model : Lia.Survey.Model.Model
    --    , narrator : String
    --    , silent : Bool
    --    , theme : String
    --    , theme_light : Bool
    }


init : Mode -> Maybe String -> Model
init mode uid =
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
    { uid = uid
    , mode = local_mode
    , sections = Array.empty
    , section_active = init_section uid
    , definition = Definition.default
    , design =
        { theme = init_design_theme
        , light = init_design_light
        }
    , loc = True
    , index_model = Index.init

    --    , show_contents = True
    --    , quiz_model = Array.empty
    --    , code_model = Array.empty
    --    , survey_model = Array.empty
    --    , index_model = Index.init []
    --    , effect_model = Effect.init "US English Male" Nothing
    --    , narrator = "US English Male"
    --    , silent = local_silent
    --    , theme = init_theme
    --    , theme_light = local_light
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


init_section : Maybe String -> Int
init_section uid =
    0



--    uid
--        |> Maybe.andThen get_local
--        |> Maybe.andThen String.toInt
--        |> Result.toMaybe
--        |> Maybe.withDefault 0


init_sound : Bool
init_sound =
    "silent"
        |> get_local
        |> Maybe.andThen (\b -> b /= "false" |> Just)
        |> Maybe.withDefault True
