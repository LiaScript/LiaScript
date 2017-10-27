module Lia.Model exposing (..)

import Array exposing (Array)
import Lia.Code.Model
import Lia.Definition.Types as Definition exposing (Definition)
import Lia.Effect.Model
import Lia.Index.Model
import Lia.Quiz.Model
import Lia.Survey.Model
import Lia.Types exposing (Mode, Slide)
import Lia.Utils exposing (get_local, load_js, set_local)


type alias Model =
    { uid : Maybe String
    , mode : Mode
    , slides : Array Slide
    , current_slide : Int
    , definition : Definition
    , style :
        { theme : String
        , light : String
        }

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

                Just "Slides_only" ->
                    Lia.Types.Slides_only

                _ ->
                    mode
    in
    { uid = uid
    , mode = local_mode
    , slides = Array.empty
    , current_slide = init_slide_number uid
    , definition = Definition.default
    , style =
        { theme = init_style_theme
        , light = init_style_light
        }

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


init_style_theme : String
init_style_theme =
    "theme"
        |> get_local
        |> Maybe.withDefault "default"


init_style_light : String
init_style_light =
    "theme_light"
        |> get_local
        |> Maybe.withDefault "light"


init_slide_number : Maybe String -> Int
init_slide_number uid =
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
